## データ出典

[つくば市](https://www.city.tsukuba.lg.jp/)が公開しているオープンデータを整備して提供しています。

人口統計と自治体標準オープンデータセットの各一覧は[つくば市オープンデータカタログ](https://t1070170.dupf.jp/ckan/)（CKAN）から、ビルドのたびに取り直します。人口統計は全時点を取ります。上流に新しい時点が増えれば次のビルドで自動的に入るので、モデルを足す作業は要りません。

上流は CP932 と UTF-8 が混在しています。読み手が単一の encoding を指定できるよう、取得の時点で UTF-8 に揃えています。

## テーブル: mart_tsukuba_population

つくば市内の地区別・性別・年齢階級別の人口データです。2003年4月以降、4月・5月・10月を中心に年2〜3回の時点を収録しています。

すべての時点に同じ地区が揃っているわけではありません。新しい住宅地は途中から現れ、古い地区は途中で消えることがあります。地区を跨いで比べるときは同じ `reference_date` で揃えてください。

- lg_code: 全国地方公共団体コード
- area_code / area_name: 地域コード / 地域名
- reference_date: 調査年月日
- sex: 性別（male / female）
- age_group: 年齢階級（0-4, 5-9, ..., 85+）
- population: 人口

## テーブル: mart_tsukuba_emergency_shelter

つくば市の指定緊急避難場所の一覧です。公式 CSV を自治体標準オープンデータセット（ODF）形式に整形し、住所正規化で緯度経度を補完しています。

- shelter_id: 避難場所 ID
- name / address: 名称 / 所在地
- pref / city / town / addr_detail: 正規化後の住所要素
- latitude / longitude: 緯度・経度（Geolonia でジオコーディング）
- flood / landslide / storm_surge / earthquake / tsunami / large_fire / inland_flooding / volcanic: 災害種別の対応フラグ
- url: 出典ページ URL

### 取得元と件数

取得元は市の公式ページに置かれた CSV 1 本で、`sources` にページと CSV の両方を挙げています。

- CSV: https://www.city.tsukuba.lg.jp/material/files/group/4/202412hinannbasyo.csv
- 時点: 2024 年 12 月
- 件数: 11 件（No.1〜11）。CSV は 4 列で、ODF 形式の 39 列へ整形しています

`mart_tsukuba_emergency_shelter` の行数は、この CSV の件数と一致します。件数を根拠に使うときは、
つくば市の指定避難所や、国土地理院の全国データ（`gsi`）に含まれる同名の施設と混ぜないでください。
指定の趣旨も収録項目も別で、件数は一致しません。

### データ更新手順

公式 CSV が更新されたら、`scripts/convert_shelter.py` で seeds を再生成します。

```bash
uv sync --extra convert
uv run python scripts/convert_shelter.py \
    https://www.city.tsukuba.lg.jp/soshikikarasagasu/shichokoshitsukikikanrika/gyomuannai/1/2/1000608.html \
    seeds/tsukuba_emergency_shelter_20241201.csv
```

出力時点のファイル名（`20241201` 部分）は、つくば市公式ページの更新時点に合わせて付けます。

## ライセンス

[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)

## テーブル: ods.evacuation_space

つくば市の指定緊急避難場所を、デジタル庁「自治体標準オープンデータセット」の指定緊急避難場所一覧の定義書どおりの列名（日本語）・並び・書き方で並べたビューです。Queria から CSV や Excel でダウンロードすれば、そのまま標準形式のファイルとして使えます。

中身は `mart_tsukuba_emergency_shelter` と同じ 11 件です。SQL や地図で使うときは、英語の列名を持つそちらが扱いやすいです。

## テーブル: mart_tsukuba_public_wireless_lan / ods.public_wireless_lan

つくば市の公衆無線LANアクセスポイント一覧です（CKAN `k006_001`）。1行が設置場所と SSID の組で、同じ施設に SSID が複数あれば施設は複数行に現れます。元データに緯度経度はありません。

- local_government_code: 全国地方公共団体コード
- facility_id: ID（市が付けた番号）
- name / name_kana / name_en: 名称 / カナ / 英語
- full_address / prefecture / city / building_name: 所在地 / 都道府県 / 市区町村 / 方書
- installer: 設置者
- phone_number / phone_ext: 電話番号 / 内線番号
- ssid / coverage_area: SSID / 提供エリア
- url / notes: URL / 備考

`ods.public_wireless_lan` は同じ行を、自治体標準オープンデータセットの定義書どおりの列名・並び（28列）で並べたビューです。

## テーブル: mart_tsukuba_fire_hydrant / ods.fire_hydrant

つくば市の消防水利の一覧です（CKAN `n007_001`）。防火水槽と消火栓の CSV 2本を1つの表にまとめ、種別で分けています。住所はありません。

- local_government_code: 全国地方公共団体コード
- facility_id: ID（支援系水利番号）
- facility_type: 種別（消火栓 / 防火水槽）
- latitude / longitude: 緯度 / 経度（日本の範囲に入らない値は NULL）
- diameter: 口径（消火栓の管径、ミリメートル）
- capacity: 容量（防火水槽のみ。単位は元データに書かれていない）
- fire_station / ownership: 管轄署所 / 公私別区分

`ods.fire_hydrant` は同じ行を、定義書どおりの列名・並び（16列）で並べたビューです。容量・管轄署所・公私別区分は定義書に列が無いので含みません。

## テーブル: mart_tsukuba_polling_place / ods.polling_place

つくば市の投票所一覧です（CKAN `m027_001`）。地区別に分かれたシートを1つの表にまとめています。期日前投票所と緯度経度は元データにありません。

- local_government_code: 全国地方公共団体コード
- voting_district_number: 投票区番号
- name / full_address: 名称 / 所在地（「茨城県つくば市」を前に付けている）
- prefecture / city: 都道府県 / 市区町村
- polling_place_type: 投票所区分（投票所）
- voting_district: 投票区名
- target_areas: 対象地区
- region: 地区（元のシート名）

`ods.polling_place` は同じ行を、自治体標準オープンデータセットのデータ項目定義書 C「投票所一覧」の列名・並び（31列）で並べたビューです。ID には投票区番号を使います。対象地区は定義書に列が無いので含みません。

## テーブル: mart_tsukuba_care_service / ods.care_service

つくば市の介護保険事業所一覧です（CKAN `o009_001`）。1行が事業所とサービスの組です。事業所名・サービス種類・所在地・電話番号・法人名・介護保険事業所番号・定員・指定年月日を持ちます。緯度経度はありません。介護保険事業所番号は、元データで落ちている先頭の 0 を補って 10 桁にしています。

`ods.care_service` は同じ行を、定義書A「介護サービス事業所一覧」の列名・並び（36列）で並べたビューです。

## テーブル: mart_tsukuba_preschool / ods.preschool

つくば市の子育て施設の一覧です。認可保育所等一覧（`o019_001`）・私立幼稚園・認定こども園一覧（`l012_001`）・市立幼稚園一覧（`sirituyoutien`）・地域子育て支援拠点（`o014_001`）を1つにまとめ、元の一覧を `source_dataset` に持ちます。全施設に緯度経度があります。

- 私立幼稚園・認定こども園一覧の認定こども園は認可保育所等一覧と同じ施設なので、認可保育所等一覧の行だけを残しています
- 地域子育て支援拠点の一覧にある出張子育て広場は、施設ではないので含みません

`ods.preschool` は定義書A「子育て施設一覧」の列名・並び（53列）で並べたビューです。種別は定義書の選択肢に読み替えています。型が書かれていない認定こども園は種別を空欄にしています。

## テーブル: mart_tsukuba_educational_institution / ods.educational_institution

つくば市立の小学校・中学校・義務教育学校・幼稚園の一覧です（CKAN `l010_001`）。学校種・所在地・電話番号・通学区域を持ちます。緯度経度と学校コードはありません。

`ods.educational_institution` は定義書C「教育機関一覧」の列名・並び（23列）で並べたビューです。所在地は町字と番地以下に分けています。

## テーブル: mart_tsukuba_bicycle_parking / ods.bicycle_parking

つくば市の自転車等駐車場の一覧です（CKAN `j008_001`）。工区に分かれた駐輪場は1行にまとめています。最寄りの TX 駅・利用時間・定期と一時の料金と台数を持ちます。緯度経度はありません。

`ods.bicycle_parking` は定義書C「公営駐輪場一覧」の列名・並び（40列）で並べたビューです。料金と利用時間は料金備考・日時備考に文章のまま入れ、最大駐輪台数には全車種の台数の合計を入れています。

## テーブル: mart_tsukuba_parking / ods.parking

つくば市の駅前広場駐車場（送迎用）の一覧です（CKAN `j009_001`）。緯度経度はありません。

`ods.parking` は定義書C「公営駐車場一覧」の列名・並び（43列）で並べたビューです。台数は車種ごとに分かれていないので、最大駐車台数の列は空欄です。

## テーブル: mart_tsukuba_open_data_list / ods.open_data_list

つくば市のオープンデータ一覧です（CKAN `m009_001`）。データ名称・分類・掲載ページの URL・ライセンス・最終更新日を持ちます。

`ods.open_data_list` は定義書A「オープンデータ一覧」の列名・並び（45列）で並べたビューです。
