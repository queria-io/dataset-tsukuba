"""つくば市オープンデータのデータパイプライン。

1. population: 地域・年齢別人口を CKAN から取得
2. ods:        自治体標準オープンデータセットの各一覧を CKAN から取得
3. dbt:        ビルド

取得を毎回やり直すので、上流に新しい時点が増えれば次のビルドで自動的に入る。
モデル側にファイルを足す作業は要らない。
"""

import logging

from dbt.cli.main import dbtRunner

from pipelines.ods import (
    download_bicycle_parking,
    download_care_service,
    download_educational_institution,
    download_fire_hydrant,
    download_open_data_list,
    download_parking,
    download_polling_place,
    download_preschool,
    download_public_wireless_lan,
)
from pipelines.population import download_population

logging.basicConfig(level=logging.INFO, format="%(message)s")
logger = logging.getLogger("pipelines")


def dbt_build():
    dbt = dbtRunner()
    for command in (["deps"], ["seed"], ["run"], ["docs", "generate"]):
        result = dbt.invoke(command)
        if not result.success:
            raise SystemExit(f"dbt {' '.join(command)} failed")


def main():
    logger.info("1/3: population (地域・年齢別人口)")
    download_population("data/population")

    logger.info("2/3: ods (自治体標準オープンデータセットの各一覧)")
    download_public_wireless_lan("data/public_wireless_lan")
    download_fire_hydrant("data/fire_hydrant")
    download_polling_place("data/polling_place", "data/polling_place.csv")
    download_care_service("data/xlsx", "data/care_service.csv")
    download_preschool("data/preschool")
    download_educational_institution("data/xlsx", "data/educational_institution.csv")
    download_bicycle_parking("data/xlsx", "data/bicycle_parking.csv")
    download_parking("data/xlsx", "data/parking.csv")
    download_open_data_list("data/open_data_list")

    logger.info("3/3: dbt build")
    dbt_build()


if __name__ == "__main__":
    main()
