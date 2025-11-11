"""
あゆみSaaS サンプルデータ生成スクリプト v2.0

就労移行支援事業所向けSaaS『あゆみ』のサンプルデータを生成します。

生成データ:
- 事業所: 4拠点
- 利用者: 100名（各事業所25名）
- スタッフ: 20名（各事業所5名）
- 期間: 2023年1月〜2024年12月（2年間）
- 出席記録: 約52,800件
- 日報: 約92,400件
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from faker import Faker

# 日本語ロケール設定
fake = Faker('ja_JP')
np.random.seed(42)

# ========================================
# 定数定義
# ========================================
NUM_FACILITIES = 4           # 事業所数
NUM_USERS_PER_FACILITY = 25  # 各事業所の利用者数
NUM_STAFFS_PER_FACILITY = 5  # 各事業所のスタッフ数
NUM_USERS = NUM_FACILITIES * NUM_USERS_PER_FACILITY    # 総利用者数: 100名
NUM_STAFFS = NUM_FACILITIES * NUM_STAFFS_PER_FACILITY  # 総スタッフ数: 20名
START_DATE = datetime(2023, 1, 1)
END_DATE = datetime(2024, 12, 31)

# 事業所マスタ
FACILITIES = [
    {'id': 1, 'name': '本社事業所', 'location': '東京'},
    {'id': 2, 'name': '横浜事業所', 'location': '神奈川'},
    {'id': 3, 'name': '大阪事業所', 'location': '大阪'},
    {'id': 4, 'name': '福岡事業所', 'location': '福岡'},
]

# 祝日リスト（2023-2024年）
HOLIDAYS = [
    # 2023年
    datetime(2023, 1, 1), datetime(2023, 1, 2), datetime(2023, 1, 9),
    datetime(2023, 2, 11), datetime(2023, 2, 23),
    datetime(2023, 3, 21),
    datetime(2023, 4, 29),
    datetime(2023, 5, 3), datetime(2023, 5, 4), datetime(2023, 5, 5),
    datetime(2023, 7, 17),
    datetime(2023, 8, 11),
    datetime(2023, 9, 18), datetime(2023, 9, 23),
    datetime(2023, 10, 9),
    datetime(2023, 11, 3), datetime(2023, 11, 23),
    # 2024年
    datetime(2024, 1, 1), datetime(2024, 1, 8),
    datetime(2024, 2, 11), datetime(2024, 2, 12), datetime(2024, 2, 23),
    datetime(2024, 3, 20),
    datetime(2024, 4, 29),
    datetime(2024, 5, 3), datetime(2024, 5, 4), datetime(2024, 5, 5), datetime(2024, 5, 6),
    datetime(2024, 7, 15),
    datetime(2024, 8, 11), datetime(2024, 8, 12),
    datetime(2024, 9, 16), datetime(2024, 9, 22), datetime(2024, 9, 23),
    datetime(2024, 10, 14),
    datetime(2024, 11, 3), datetime(2024, 11, 4), datetime(2024, 11, 23),
]

# ========================================
# 1. 利用者マスタ生成
# ========================================
def generate_users(num_users, facilities):
    """利用者データを生成"""
    users = []

    for i in range(1, num_users + 1):
        # 事業所割り当て
        facility_id = ((i - 1) // NUM_USERS_PER_FACILITY) + 1

        # 利用開始日: 過去2年以内
        start_date = START_DATE - timedelta(days=np.random.randint(30, 730))

        # 4つのセグメント（事業所内での割合）
        facility_index = (i - 1) % NUM_USERS_PER_FACILITY
        if facility_index < 7:  # 優良層（30%）
            attendance_segment = 'high'
        elif facility_index < 17:  # 良好層（40%）
            attendance_segment = 'medium'
        elif facility_index < 22:  # 要注意層（20%）
            attendance_segment = 'attention'
        else:  # 要支援層（10%）
            attendance_segment = 'support'

        user = {
            'id': i,
            'facility_id': facility_id,
            'name': fake.name(),
            'name_kana': fake.kana_name(),
            'login_code': f'user{i:03d}',
            'email': f'user{i:03d}@example.com',
            'start_date': start_date.strftime('%Y-%m-%d'),
            'end_date': None,
            'is_active': True,
            'attendance_segment': attendance_segment,  # 内部管理用
        }
        users.append(user)

    df = pd.DataFrame(users)

    # 出力用に不要なカラムを削除
    df_output = df.drop(columns=['attendance_segment'])

    return df, df_output


# ========================================
# 2. スタッフマスタ生成
# ========================================
def generate_staffs(num_staffs, facilities):
    """スタッフデータを生成"""
    staffs = []

    for i in range(1, num_staffs + 1):
        # 事業所割り当て
        facility_id = ((i - 1) // NUM_STAFFS_PER_FACILITY) + 1

        # 各事業所の最初のスタッフを管理者に
        if (i - 1) % NUM_STAFFS_PER_FACILITY == 0:
            role = 'admin'
        else:
            role = 'staff'

        staff = {
            'id': i,
            'facility_id': facility_id,
            'name': fake.name(),
            'email': f'staff{i}@ayumi.example.com',
            'role': role,
            'is_active': True,
        }
        staffs.append(staff)

    return pd.DataFrame(staffs)


# ========================================
# 3. 出席記録生成
# ========================================
def generate_attendance_records(users_df, staffs_df):
    """出席記録を生成"""
    records = []

    # 営業日リスト（月〜金、祝日除外）
    business_days = []
    current = START_DATE
    while current <= END_DATE:
        if current.weekday() < 5 and current not in HOLIDAYS:  # 月〜金
            business_days.append(current)
        current += timedelta(days=1)

    print(f"   営業日数: {len(business_days)}日")

    for _, user in users_df.iterrows():
        user_start = datetime.strptime(user['start_date'], '%Y-%m-%d')

        # 出席率をセグメント別に設定
        if user['attendance_segment'] == 'high':
            base_attendance_rate = 0.95
        elif user['attendance_segment'] == 'medium':
            base_attendance_rate = 0.80
        elif user['attendance_segment'] == 'attention':
            base_attendance_rate = 0.60
        else:  # support
            base_attendance_rate = 0.40

        # 同じ事業所のスタッフIDリスト
        facility_staffs = staffs_df[staffs_df['facility_id'] == user['facility_id']]['id'].tolist()

        for date in business_days:
            if date < user_start:
                continue

            # 出席判定
            if np.random.random() < base_attendance_rate:
                attendance_type = 'onsite' if np.random.random() < 0.9 else 'remote'
            else:
                attendance_type = 'absent'

            # 時間帯（終日が多い）
            time_slot = np.random.choice(['am', 'pm', 'full'], p=[0.1, 0.1, 0.8])

            record = {
                'id': len(records) + 1,
                'user_id': user['id'],
                'facility_id': user['facility_id'],
                'record_date': date.strftime('%Y-%m-%d'),
                'record_time_slot': time_slot,
                'attendance_type': attendance_type,
                'is_approved': True,
                'approved_by': np.random.choice(facility_staffs),
            }
            records.append(record)

    return pd.DataFrame(records)


# ========================================
# 4. 朝日報生成
# ========================================
def generate_morning_reports(attendance_df):
    """朝日報を生成"""
    reports = []

    # 出席日のみ日報を記録
    attendance_days = attendance_df[
        attendance_df['attendance_type'].isin(['onsite', 'remote'])
    ]

    for _, record in attendance_days.iterrows():
        # 睡眠時間: 5-9時間（正規分布）
        sleep_minutes = int(np.random.normal(390, 60))  # 平均6.5時間
        sleep_minutes = np.clip(sleep_minutes, 240, 540)

        # ストレス評価: 睡眠時間と相関
        if sleep_minutes < 360:  # 6時間未満
            stress_rating = np.random.choice([1, 2], p=[0.3, 0.7])
        elif sleep_minutes < 420:  # 6-7時間
            stress_rating = np.random.choice([2, 3], p=[0.6, 0.4])
        else:  # 7時間以上
            stress_rating = np.random.choice([2, 3], p=[0.2, 0.8])

        # 睡眠評価: 睡眠時間から算出
        if sleep_minutes >= 420:
            sleep_rating = 3
        elif sleep_minutes >= 360:
            sleep_rating = 2
        else:
            sleep_rating = 1

        # 食事評価
        meal_rating = np.random.choice([1, 2, 3], p=[0.1, 0.3, 0.6])

        # 気分スコア: ストレスと相関
        if stress_rating == 1:
            mood_score = np.random.randint(3, 6)
        elif stress_rating == 2:
            mood_score = np.random.randint(5, 8)
        else:
            mood_score = np.random.randint(7, 11)

        report = {
            'id': len(reports) + 1,
            'user_id': record['user_id'],
            'facility_id': record['facility_id'],
            'report_date': record['record_date'],
            'sleep_rating': sleep_rating,
            'stress_rating': stress_rating,
            'meal_rating': meal_rating,
            'sleep_minutes': sleep_minutes,
            'mid_awaken_count': np.random.randint(0, 4),
            'is_early_awaken': np.random.choice([True, False], p=[0.2, 0.8]),
            'is_breakfast_done': np.random.choice([True, False], p=[0.8, 0.2]),
            'is_bathing_done': np.random.choice([True, False], p=[0.9, 0.1]),
            'mood_score': mood_score,
            'sign_good': np.random.randint(0, 4),
            'sign_caution': np.random.randint(0, 3),
            'sign_bad': np.random.randint(0, 2),
        }
        reports.append(report)

    return pd.DataFrame(reports)


# ========================================
# 5. 夕日報生成
# ========================================
def generate_evening_reports(attendance_df):
    """夕日報を生成"""
    reports = []

    # 出席日のみ日報を記録
    attendance_days = attendance_df[
        attendance_df['attendance_type'].isin(['onsite', 'remote'])
    ]

    training_contents = [
        'PCスキル訓練',
        'ビジネスマナー',
        '履歴書作成',
        '模擬面接',
        'グループワーク',
        '個別学習',
    ]

    for _, record in attendance_days.iterrows():
        # 訓練時間: 1-4時間
        training_minutes = np.random.randint(60, 241)

        # 自己評価: 訓練時間と相関
        if training_minutes >= 180:
            self_evaluation = np.random.choice([4, 5], p=[0.4, 0.6])
        elif training_minutes >= 120:
            self_evaluation = np.random.choice([3, 4], p=[0.5, 0.5])
        else:
            self_evaluation = np.random.choice([2, 3], p=[0.6, 0.4])

        report = {
            'id': len(reports) + 1,
            'user_id': record['user_id'],
            'facility_id': record['facility_id'],
            'report_date': record['record_date'],
            'training_summary': np.random.choice(training_contents),
            'training_minutes': training_minutes,
            'self_evaluation': self_evaluation,
        }
        reports.append(report)

    return pd.DataFrame(reports)


# ========================================
# メイン処理
# ========================================
def main():
    """メイン処理"""
    print("=" * 70)
    print("あゆみSaaS サンプルデータ生成 v2.0")
    print("=" * 70)
    print(f"期間: {START_DATE.strftime('%Y-%m-%d')} 〜 {END_DATE.strftime('%Y-%m-%d')}")
    print(f"事業所数: {NUM_FACILITIES}拠点")
    print(f"利用者数: {NUM_USERS}名（各事業所{NUM_USERS_PER_FACILITY}名）")
    print(f"スタッフ数: {NUM_STAFFS}名（各事業所{NUM_STAFFS_PER_FACILITY}名）")
    print("=" * 70)

    # 1. 利用者マスタ
    print("\n1. 利用者マスタ生成中...")
    users_df, users_output_df = generate_users(NUM_USERS, FACILITIES)
    users_output_df.to_csv('ayumi_users.csv', index=False, encoding='utf-8')
    print(f"   ✅ ayumi_users.csv 生成完了（{len(users_df)}行）")

    # 2. スタッフマスタ
    print("\n2. スタッフマスタ生成中...")
    staffs_df = generate_staffs(NUM_STAFFS, FACILITIES)
    staffs_df.to_csv('ayumi_staffs.csv', index=False, encoding='utf-8')
    print(f"   ✅ ayumi_staffs.csv 生成完了（{len(staffs_df)}行）")

    # 3. 出席記録
    print("\n3. 出席記録生成中...")
    attendance_df = generate_attendance_records(users_df, staffs_df)
    attendance_df.to_csv('ayumi_attendance_records.csv', index=False, encoding='utf-8')
    print(f"   ✅ ayumi_attendance_records.csv 生成完了（{len(attendance_df)}行）")

    # 4. 朝日報
    print("\n4. 朝日報生成中...")
    morning_df = generate_morning_reports(attendance_df)
    morning_df.to_csv('ayumi_daily_reports_morning.csv', index=False, encoding='utf-8')
    print(f"   ✅ ayumi_daily_reports_morning.csv 生成完了（{len(morning_df)}行）")

    # 5. 夕日報
    print("\n5. 夕日報生成中...")
    evening_df = generate_evening_reports(attendance_df)
    evening_df.to_csv('ayumi_daily_reports_evening.csv', index=False, encoding='utf-8')
    print(f"   ✅ ayumi_daily_reports_evening.csv 生成完了（{len(evening_df)}行）")

    print("\n" + "=" * 70)
    print("✅ 全てのサンプルデータ生成完了！")
    print("=" * 70)
    print(f"合計データ数: {len(users_df) + len(staffs_df) + len(attendance_df) + len(morning_df) + len(evening_df):,}行")

    # 統計サマリ
    print("\n📊 データサマリ:")
    print(f"   - 事業所数: {NUM_FACILITIES}拠点")
    print(f"   - 利用者数: {len(users_df)}名")
    print(f"   - スタッフ数: {len(staffs_df)}名")
    print(f"   - 出席記録: {len(attendance_df):,}件")
    print(f"   - 朝日報: {len(morning_df):,}件")
    print(f"   - 夕日報: {len(evening_df):,}件")

    # 出席率サマリ
    attendance_rate = (
        attendance_df[attendance_df['attendance_type'].isin(['onsite', 'remote'])].shape[0]
        / attendance_df.shape[0] * 100
    )
    print(f"\n   平均出席率: {attendance_rate:.1f}%")

    # 事業所別サマリ
    print("\n📍 事業所別サマリ:")
    for facility in FACILITIES:
        facility_users = users_df[users_df['facility_id'] == facility['id']]
        facility_attendance = attendance_df[attendance_df['facility_id'] == facility['id']]
        facility_rate = (
            facility_attendance[facility_attendance['attendance_type'].isin(['onsite', 'remote'])].shape[0]
            / facility_attendance.shape[0] * 100
        )
        print(f"   {facility['name']} ({facility['location']}): 利用者{len(facility_users)}名, 出席率{facility_rate:.1f}%")

    print("\n" + "=" * 70)


if __name__ == '__main__':
    main()
