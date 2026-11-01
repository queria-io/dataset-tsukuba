"""自治体標準オープンデータセットの各一覧を CKAN から取得する。

データセットごとに CKAN の ID が決まっているので、package_show でリソースを引く。
CSV は CP932 で配られているため、取得の時点で UTF-8 に揃える。
"""

from __future__ import annotations

import csv
import datetime
import logging
from pathlib import Path

from openpyxl import load_workbook

from pipelines.ckan import download, package_resources

logger = logging.getLogger("pipelines.ods")

PUBLIC_WIRELESS_LAN = "k006_001"
FIRE_HYDRANT = "n007_001"
POLLING_PLACE = "m027_001"
CARE_SERVICE = "o009_001"
NURSERY = "o019_001"
PRIVATE_KINDERGARTEN = "l012_001"
PUBLIC_KINDERGARTEN = "sirituyoutien"
CHILDCARE_SUPPORT = "o014_001"
SCHOOL = "l010_001"
BICYCLE_PARKING = "j008_001"
PARKING = "j009_001"
OPEN_DATA_LIST = "m009_001"

# 投票所一覧は地区ごとにシートが分かれている。このヘッダーで始まるシートだけを読む
# （同じブックに行政区と学区の対応表のシートが同居している）
POLLING_PLACE_HEADER = ["№", "投票区番号", "投票区", "投票所", "投票所住所", "対象地区"]
# 地区別のシートは 6 枚（2024年7月時点）。1 枚でも様式が変わって読めなくなると、
# その地区の投票所が黙って抜けるので、下回ったら止める
MIN_POLLING_PLACE_SHEETS = 6


def download_public_wireless_lan(dest: str) -> Path:
    # 時点の違う CSV が並ぶと同じアクセスポイントが二重に入るので、1 件のときだけ取る
    return download_csv(PUBLIC_WIRELESS_LAN, dest)


def download_fire_hydrant(dest: str) -> list[Path]:
    # 防火水槽と消火栓が別の CSV で載っている。種別は各 CSV の列が持つ
    _clear_csv(Path(dest))
    resources = package_resources(FIRE_HYDRANT, "CSV")
    if not resources:
        raise SystemExit("fire_hydrant: CSV が 1 件も無い。上流の構成が変わった")
    return download(resources, Path(dest), normalize_encoding=True)


def download_polling_place(dest: str, out: str) -> Path:
    """投票所一覧の XLSX を取得し、地区別のシートを縦につないだ CSV を `out` に書く。

    1 列目には元のシート名（地区）を入れる。合計行などの選別は dbt 側でする。
    """
    return download_xlsx(
        POLLING_PLACE, dest, out,
        layouts=[[POLLING_PLACE_HEADER]],
        columns=POLLING_PLACE_HEADER,
        min_sheets=MIN_POLLING_PLACE_SHEETS,
        sheet_column="地区",
    )


CARE_SERVICE_HEADER = [
    "No.", "サービスコード", "サービス種類", "介護予防", "総合事業", "介護保険事業所番号", "法人名",
    "事業所名", "電話番号", "FAX番号", "郵便番号", "所在地", "圏域", "定員", "指定年月日", "みなし区分",
]
NURSERY_HEADER = [
    "区分", "種別", "名称", "名称_カナ", "住所", "方書", "経度（世界測地系）", "緯度（世界測地系）",
    "アクセス方法", "定員", "設立年月日", "認可等年月日", "電話", "FAX番号", "法人番号", "団体名",
    "保育年齢", "送迎バス", "利用可能曜日", "利用可能日時特記事項", "開園（平日）",
    "保育標準時間（施設が定める11時間）", "保育標準時間（施設が定める8時間）", "閉園（平日）",
    "開園（土曜日）", "閉園（土曜日）", "一時預かりの有無", "URL", "備考",
]
PRIVATE_KINDERGARTEN_HEADER = [
    "区分", "種別", "名称", "住所", "対象児", "電話番号", "FAX番号", "ホームページ", "バス",
    "経度（世界測地系）", "緯度（世界測地系）",
]
CHILDCARE_SUPPORT_HEADER = ["種別", "名称", "実施日", "実施時間", "住所", "方書", "電話", "経度", "緯度"]
# 学校の種類ごとにシートが分かれている（小学校・中学校・義務教育学校・幼稚園）。
# 幼稚園のシートだけ見出しが「幼稚園名」「通園区域」になっている
SCHOOL_HEADERS = [
    ["学校名", "所在地", "電話番号", "通学区域"],
    ["幼稚園名", "所在地", "電話番号", "通園区域"],
]
SCHOOL_SHEETS = 4
# 見出しが 3 段に組まれている。上の段の見出しは左端のセルにだけ入っていて、
# 下の段の見出しと組み合わせて列の意味が決まる
BICYCLE_PARKING_LAYOUT = [
    ["TX駅", "No", "駐輪場名称", "", "所在地", "駐車区分", "利用時間", "", "", "駐車可能な車両", "",
     "料金", "", "", "", "", "", "供用台数", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", "", "", "",
     "定期", "", "", "一時", "", "", "定期", "", "", "一時", "", ""],
    ["", "", "", "", "", "", "平日", "土日祝日\n12/29～/31\n1/2～/3", "元旦", "定期", "一時",
     "自転車", "原付", "自動二輪車", "自転車", "原付", "自動二輪車",
     "自転車", "原付", "自動二輪車", "自転車", "原付", "自動二輪車"],
]
BICYCLE_PARKING_COLUMNS = [
    "TX駅", "No", "駐輪場名称", "区画", "所在地", "駐車区分",
    "利用時間_平日", "利用時間_土日祝日・12/29〜12/31・1/2〜1/3", "利用時間_元旦",
    "駐車可能な車両_定期", "駐車可能な車両_一時",
    "料金_定期_自転車", "料金_定期_原付", "料金_定期_自動二輪車",
    "料金_一時_自転車", "料金_一時_原付", "料金_一時_自動二輪車",
    "供用台数_定期_自転車", "供用台数_定期_原付", "供用台数_定期_自動二輪車",
    "供用台数_一時_自転車", "供用台数_一時_原付", "供用台数_一時_自動二輪車",
]
PARKING_HEADER = ["TX駅", "No", "駐輪場名称", "所在地", "駐車区分", "利用時間", "駐車可能な車両", "料金", "供用台数", "備考"]


def download_care_service(dest: str, out: str) -> Path:
    return download_xlsx(CARE_SERVICE, dest, out, layouts=[[CARE_SERVICE_HEADER]], columns=CARE_SERVICE_HEADER)


def download_preschool(dest: str) -> list[Path]:
    """子育て施設は 4 つのデータセットに分かれて載っている。種類ごとに 1 本ずつ CSV にする。"""
    root = Path(dest)
    return [
        download_xlsx(NURSERY, str(root / "xlsx"), str(root / "nursery.csv"),
                      layouts=[[NURSERY_HEADER]], columns=NURSERY_HEADER),
        download_xlsx(PRIVATE_KINDERGARTEN, str(root / "xlsx"), str(root / "private_kindergarten.csv"),
                      layouts=[[PRIVATE_KINDERGARTEN_HEADER]], columns=PRIVATE_KINDERGARTEN_HEADER),
        download_xlsx(CHILDCARE_SUPPORT, str(root / "xlsx"), str(root / "childcare_support.csv"),
                      layouts=[[CHILDCARE_SUPPORT_HEADER]], columns=CHILDCARE_SUPPORT_HEADER),
        download_csv(PUBLIC_KINDERGARTEN, str(root / "public_kindergarten")),
    ]


def download_educational_institution(dest: str, out: str) -> Path:
    return download_xlsx(
        SCHOOL, dest, out,
        layouts=[[h] for h in SCHOOL_HEADERS],
        columns=["学校名", "所在地", "電話番号", "通学区域"],
        min_sheets=SCHOOL_SHEETS,
    )


def download_bicycle_parking(dest: str, out: str) -> Path:
    return download_xlsx(
        BICYCLE_PARKING, dest, out, layouts=[BICYCLE_PARKING_LAYOUT], columns=BICYCLE_PARKING_COLUMNS
    )


def download_parking(dest: str, out: str) -> Path:
    return download_xlsx(PARKING, dest, out, layouts=[[PARKING_HEADER]], columns=PARKING_HEADER)


def download_open_data_list(dest: str) -> Path:
    return download_csv(OPEN_DATA_LIST, dest)


def _clear_csv(dest: Path) -> None:
    """前回の取得で残った CSV を消す。raw は glob で読むので、時点の違うファイルが残ると二重に入る"""
    for path in dest.glob("*.csv"):
        path.unlink()


def download_csv(package_id: str, dest: str) -> Path:
    """CSV が 1 本だけ載っているデータセットを取得し、UTF-8 に揃えて `dest` に置く。"""
    _clear_csv(Path(dest))
    resources = package_resources(package_id, "CSV")
    if len(resources) != 1:
        raise SystemExit(f"{package_id}: CSV が {len(resources)} 件ある (1 件のはず)。上流の構成が変わった")
    (path,) = download(resources, Path(dest), normalize_encoding=True)
    return path


def download_xlsx(
    package_id: str,
    dest: str,
    out: str,
    *,
    layouts: list[list[list[str]]],
    columns: list[str],
    min_sheets: int = 1,
    sheet_column: str = "シート",
) -> Path:
    """XLSX が 1 本だけ載っているデータセットを取得し、表のシートを縦につないだ CSV を `out` に書く。

    `layouts` はシートの先頭の見出し行の並び（1 行とは限らない）の候補で、どれかに一致した
    シートだけを読む。見出しの下の行を `columns` の列名で書き出し、1 列目には元のシート名を入れる。
    一致したシートが `min_sheets` に届かなければ、上流の様式が変わったとして止める。
    """
    resources = package_resources(package_id, "XLSX")
    if len(resources) != 1:
        raise SystemExit(f"{package_id}: XLSX が {len(resources)} 件ある (1 件のはず)。上流の構成が変わった")
    (xlsx,) = download(resources, Path(dest))

    width = len(columns)
    rows: list[list[str]] = []
    sheets: list[str] = []
    skipped: list[str] = []
    wb = load_workbook(xlsx, read_only=True, data_only=True)
    try:
        for ws in wb.worksheets:
            values = [r for r in ws.iter_rows(values_only=True) if any(v is not None for v in r)]
            layout = next((lo for lo in layouts if _matches(values, lo)), None)
            if layout is None:
                skipped.append(ws.title)
                continue
            sheets.append(ws.title)
            for row in values[len(layout) :]:
                cells = [_cell(v) for v in row[:width]]
                cells += [""] * (width - len(cells))
                if any(cells):
                    rows.append([ws.title, str(len(rows) + 1), *cells])
    finally:
        wb.close()
    if skipped:
        logger.warning("%s: 表の様式でないシートを読み飛ばした (%s)", package_id, "、".join(skipped))
    if len(sheets) < min_sheets:
        raise SystemExit(
            f"{package_id}: 表のシートが {len(sheets)} 枚しかない ({min_sheets} 枚のはず)。上流の様式が変わった"
        )

    path = Path(out)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f)
        writer.writerow([sheet_column, "行", *columns])
        writer.writerows(rows)
    logger.info("%s: %d シート %d 行", package_id, len(sheets), len(rows))
    return path


def _matches(values: list[tuple], layout: list[list[str]]) -> bool:
    if len(values) < len(layout):
        return False
    return all(
        [_cell(v) for v in values[i][: len(expected)]] == expected for i, expected in enumerate(layout)
    )


def _cell(value: object) -> str:
    # Excel の日付・時刻はそのまま str にすると秒や 00:00:00 が付くので、定義書の書き方に寄せる
    if isinstance(value, datetime.datetime):
        return value.date().isoformat()
    if isinstance(value, datetime.time):
        return value.strftime("%H:%M")
    # 整数のセルが 120.0 のような小数で返ることがある
    if isinstance(value, float) and value.is_integer():
        return str(int(value))
    return "" if value is None else str(value).strip()
