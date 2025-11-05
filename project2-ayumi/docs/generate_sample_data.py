"""
あゆみSaaS サンプルデータ生成スクリプト

就労移行支援事業所向けSaaS『あゆみ』のサンプルデータを生成します。

生成データ:
- 利用者: 25名
- スタッフ: 5名
- 期間: 2024年10月〜12月（3ヶ月）
- 出席記録: 約1,650件
- 日報: 約2,898件
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
NUM_USERS = 25
NUM_STAFFS = 5
START_DATE = datetime(2024, 10, 1)
END_DATE = datetime(2024, 12, 31)

# 祝日リスト（2024年10-12月）
HOLIDAYS = [
    datetime(2024, 10, 14),  # 体育の日
    datetime(2024, 11, 3),   # 文化の日
    datetime(2024, 11, 4),   # 振替休日
    datetime(2024, 11, 23),  # 勤労感謝の日
]

# ========================================
# 1. 利用者マスタ生成
# ========================================
def generate_users(num_users):
    """利用者データを生成"""
    users = []
    
    for i in range(1, num_users + 1):
        # 利用開始日: 過去1年以内
        start_date = START_DATE - timedelta(days=np.random.randint(30, 365))
        
        # 4つのセグメント
        if i <= 7:  # 優良層（30%）
            attendance_segment = 'high'
        elif i <= 17:  # 良好層（40%）
            attendance_segment = 'medium'
        elif i <= 22:  # 要注意層（20%）
            attendance_segment = 'attention'
        else:  # 要支援層（10%）
            attendance_segment = 'support'
        
        user = {
            'id': i,
            'name': fake.name(),
            'name_kana': fake.kana_name(),
            'login_code': f'user{i:03d}',
            'email': f'user{i:03d}@example.com',
            'start_date': start_date.strftime('%Y-%m-%d'),
            'end_date': None,
            'is_active': True,
            'attendance_segment': attendance_segment,  # 内部管理用（CSVには含めない）
        }
        users.append(user)
    
    df = pd.DataFrame(users)
    
    # 出力用に不要なカラムを削除
    df_output = df.drop(columns=['attendance_segment'])
    
    return df, df_output


# ========================================
# 2. スタッフマスタ生成
# ========================================
def generate_staffs(num_staffs):
    """スタッフデータを生成"""
    staffs = []
    
    roles = ['admin'] + ['staff'] * (num_staffs - 1)
    
    for i, role in enumerate(roles, start=1):
        staff = {
            'id': i,
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
def generate_attendance_records(users_df):
    """出席記録を生成"""
    records = []
    
    # 営業日リスト（月〜金、祝日除外）
    business_days = []
    current = START_DATE
    while current <= END_DATE:
        if current.weekday() < 5 and current not in HOLIDAYS:  # 月〜金
            business_days.append(current)
        current += timedelta(days=1)
    
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
                'record_date': date.strftime('%Y-%m-%d'),
                'record_time_slot': time_slot,
                'attendance_type': attendance_type,
                'is_approved': True,
                'approved_by': np.random.randint(1, NUM_STAFFS + 1),
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
    print("あゆみSaaS サンプルデータ生成開始...")
    print(f"期間: {START_DATE.strftime('%Y-%m-%d')} 〜 {END_DATE.strftime('%Y-%m-%d')}")
    print(f"利用者数: {NUM_USERS}名")
    print(f"スタッフ数: {NUM_STAFFS}名")
    print("-" * 60)
    
    # 1. 利用者マスタ
    print("1. 利用者マスタ生成中...")
    users_df, users_output_df = generate_users(NUM_USERS)
    users_output_df.to_csv('ayumi_users.csv', index=False, encoding='utf-8')
    print(f"   ✅ ayumi_users.csv 生成完了（{len(users_df)}行）")
    
    # 2. スタッフマスタ
    print("2. スタッフマスタ生成中...")
    staffs_df = generate_staffs(NUM_STAFFS)
    staffs_df.to_csv('ayumi_staffs.csv', index=False, encoding='utf-8')
    print(f"   ✅ ayumi_staffs.csv 生成完了（{len(staffs_df)}行）")
    
    # 3. 出席記録
    print("3. 出席記録生成中...")
    attendance_df = generate_attendance_records(users_df)
    attendance_df.to_csv('ayumi_attendance_records.csv', index=False, encoding='utf-8')
    print(f"   ✅ ayumi_attendance_records.csv 生成完了（{len(attendance_df)}行）")
    
    # 4. 朝日報
    print("4. 朝日報生成中...")
    morning_df = generate_morning_reports(attendance_df)
    morning_df.to_csv('ayumi_daily_reports_morning.csv', index=False, encoding='utf-8')
    print(f"   ✅ ayumi_daily_reports_morning.csv 生成完了（{len(morning_df)}行）")
    
    # 5. 夕日報
    print("5. 夕日報生成中...")
    evening_df = generate_evening_reports(attendance_df)
    evening_df.to_csv('ayumi_daily_reports_evening.csv', index=False, encoding='utf-8')
    print(f"   ✅ ayumi_daily_reports_evening.csv 生成完了（{len(evening_df)}行）")
    
    print("-" * 60)
    print("✅ 全てのサンプルデータ生成完了！")
    print(f"合計データ数: {len(users_df) + len(staffs_df) + len(attendance_df) + len(morning_df) + len(evening_df)}行")
    
    # 統計サマリ
    print("\n📊 データサマリ:")
    print(f"   - 利用者数: {len(users_df)}名")
    print(f"   - スタッフ数: {len(staffs_df)}名")
    print(f"   - 出席記録: {len(attendance_df)}件")
    print(f"   - 朝日報: {len(morning_df)}件")
    print(f"   - 夕日報: {len(evening_df)}件")
    
    # 出席率サマリ
    attendance_rate = (
        attendance_df[attendance_df['attendance_type'].isin(['onsite', 'remote'])].shape[0] 
        / attendance_df.shape[0] * 100
    )
    print(f"\n   平均出席率: {attendance_rate:.1f}%")


if __name__ == '__main__':
    main()