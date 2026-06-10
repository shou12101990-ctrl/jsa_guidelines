#!/usr/bin/env python3
"""日本麻酔科学会ガイドラインのマニフェスト生成 + PDF一括ダウンロード"""
import json
import os
import subprocess
import sys

BASE = "https://anesth.or.jp"
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PDF_DIR = os.path.join(ROOT, "assets", "pdfs")
DATA_DIR = os.path.join(ROOT, "assets", "data")

# (category, title, path_or_url, external)
ITEMS = [
    # ── 教育ガイドライン ──
    ("教育", "教育ガイドライン改訂第4版", "/files/pdf/kyoiku4_20220627.pdf", False),

    # ── 本学会制定ガイドライン ──
    ("本学会制定ガイドライン", "悪性高熱症管理ガイドライン", "/files/pdf/guideline_akuseikounetsu.pdf", False),
    ("本学会制定ガイドライン", "麻酔器の始業点検", "/files/pdf/guideline_checkout_20221117.pdf", False),
    ("本学会制定ガイドライン", "WHO 安全な手術のためのガイドライン2009", "/files/pdf/20150526guideline.pdf", False),
    ("本学会制定ガイドライン", "WHO手術安全チェックリスト（2009年改訂版）", "/files/pdf/20150526checklist.pdf", False),
    ("本学会制定ガイドライン", "気道管理ガイドライン2014（日本語訳）", "/files/pdf/20150427-2guidelin.pdf", False),
    ("本学会制定ガイドライン", "気道管理ガイドライン2014 図表集", "/files/pdf/20150427-2zukei.pdf", False),
    ("本学会制定ガイドライン", "無呼吸テスト実施指針", "/files/pdf/guideline_MukokyuTest.pdf", False),
    ("本学会制定ガイドライン", "薬剤シリンジラベルに関する提言", "/files/pdf/guideline_0604.pdf", False),
    ("本学会制定ガイドライン", "周術期禁煙プラクティカルガイド", "/files/pdf/kinen-practical-guide_20210928.pdf", False),
    ("本学会制定ガイドライン", "周術期禁煙ガイドライン", "/files/pdf/20150409-1guidelin.pdf", False),
    ("本学会制定ガイドライン", "周術期禁煙ガイドライン追補版", "/files/pdf/20180403-guideline.pdf", False),
    ("本学会制定ガイドライン", "禁煙啓発ポスター（医療従事者向け）", "/files/pdf/kinen-p-1.pdf", False),
    ("本学会制定ガイドライン", "禁煙啓発ポスター（一般の皆様向け）", "/files/pdf/kinen-p-2_20190107.pdf", False),
    ("本学会制定ガイドライン", "周術期禁煙啓発リーフレット", "/files/pdf/kinen-p-3_20210121.pdf", False),
    ("本学会制定ガイドライン", "周術期禁煙啓発動画", "https://anesth.or.jp/users/person/guide_line/perioperative_smoking_video", True),
    ("本学会制定ガイドライン", "骨髄バンクドナーに対する麻酔管理", "/files/pdf/guideline_donor_20200828.pdf", False),
    ("本学会制定ガイドライン", "安全な麻酔のためのモニター指針", "/files/pdf/monitor3.pdf", False),
    ("本学会制定ガイドライン", "「筋弛緩のチェックについて」に関するFAQ", "/files/pdf/faq_muscle_relaxation_check.pdf", False),
    ("本学会制定ガイドライン", "術前絶飲食ガイドライン", "/files/pdf/kangae2.pdf", False),
    ("本学会制定ガイドライン", "Awake craniotomy麻酔管理のガイドライン", "/files/pdf/guideline_awake.pdf", False),
    ("本学会制定ガイドライン", "脳死体からの臓器移植に関する指針", "/files/pdf/guideline_transplant2.pdf", False),
    ("本学会制定ガイドライン", "麻酔関連業務における特定行為研修修了看護師の安全管理指針", "/files/pdf/guideline_safetymanagement.pdf", False),
    ("本学会制定ガイドライン", "特定行為研修修了看護師の安全管理指針 FAQ", "/files/pdf/guideline_safetymanagement_faq.pdf", False),
    ("本学会制定ガイドライン", "特定行為研修修了看護師の安全管理指針 FAQ2", "/files/pdf/guideline_safetymanagement_faq_2.pdf", False),
    ("本学会制定ガイドライン", "全身麻酔用医薬品投与制御プログラムに関する適正使用指針", "/files/pdf/guideline_drug_administration_control_program.pdf", False),
    ("本学会制定ガイドライン", "臨床工学技士の術中麻酔関連補助業務に関する安全管理指針", "/files/pdf/safety_management_guideline_clinical_engineers.pdf", False),
    ("本学会制定ガイドライン", "臨床工学技士の安全管理指針 FAQ", "/files/pdf/safety_management_guideline_clinical_engineers_faq.pdf", False),
    ("本学会制定ガイドライン", "抜管から術後早期までの安全な気道管理のための臨床ガイドライン", "/files/pdf/safe_airway_management_extubation_early_postoperative_period.pdf", False),
    ("本学会制定ガイドライン", "抜管から術後早期までの安全な気道管理（ダイジェスト版）", "/files/pdf/safe_airway_management_extubation_early_postoperative_period_digest.pdf", False),

    # ── 本学会制定プラクティカルガイド ──
    ("プラクティカルガイド", "安全な鎮静のためのプラクティカルガイド", "/files/pdf/practical_guide_for_safe_sedation_20220628.pdf", False),
    ("プラクティカルガイド", "術中心停止に対するプラクティカルガイド", "/files/pdf/practical_guide_for_central_arrest_20220228.pdf", False),
    ("プラクティカルガイド", "アナフィラキシーに対する対応プラクティカルガイド", "/files/pdf/response_practical_guide_to_anaphylaxis.pdf", False),
    ("プラクティカルガイド", "MEPモニタリング時の麻酔管理のためのプラクティカルガイド", "/files/pdf/mep_monitoring_practical_guide.pdf", False),
    ("プラクティカルガイド", "安全な中心静脈カテーテル挿入・管理のためのプラクティカルガイド2026（早期掲載版）", "/files/pdf/JSA_CV_practical_guide_2026.pdf", False),
    ("プラクティカルガイド", "局所麻酔薬中毒への対応プラクティカルガイド", "/files/pdf/practical_localanesthesia.pdf", False),
    ("プラクティカルガイド", "麻酔科学における患者安全に関するヘルシンキ宣言（和訳）", "/files/pdf/helsinki_declaration.pdf", False),

    # ── 救急救命士気管挿管マニュアル ──
    ("救急救命士マニュアル", "救急救命士気管挿管・ビデオ硬性喉頭鏡による気管挿管実習マニュアル", "/files/pdf/intubation_training_manual.pdf", False),
    ("救急救命士マニュアル", "救急救命士気管挿管実習マニュアル FAQ", "/files/pdf/intubation_training_manual_faq.pdf", False),

    # ── 他学会合同制定ガイドライン ──
    ("他学会合同", "産科危機的出血への対応指針2022", "/files/pdf/guideline_Sanka_kiki_2022.pdf", False),
    ("他学会合同", "産科危機的出血ガイドライン2017のポスター", "/files/pdf/guideline_Sanka_kiki-p.pdf", False),
    ("他学会合同", "抗血栓療法ガイドライン", "/files/pdf/guideline_kouketsusen.pdf", False),
    ("他学会合同", "抗血栓療法ガイドライン（追補版）", "/files/pdf/guideline_kouketsusen_tsuiho.pdf", False),
    ("他学会合同", "NICUに入院している新生児の痛みのケアガイドライン（実用版）", "/files/pdf/20150323guideline.pdf", False),
    ("他学会合同", "日帰り麻酔の安全のための基準", "/files/pdf/higaerimasui.pdf", False),
    ("他学会合同", "歯科医師の医科麻酔科研修ガイドライン（2008年改訂）", "/files/pdf/20080620.pdf", False),
    ("他学会合同", "歯科医師の医科麻酔科研修のガイドライン（2026年改訂）", "/files/pdf/20260413.pdf", False),
    ("他学会合同", "歯科医師の医科麻酔科研修ガイドライン Q&A", "/files/pdf/20260422.pdf", False),
    ("他学会合同", "宗教的輸血拒否に関するガイドライン", "/files/pdf/guideline.pdf", False),
    ("他学会合同", "未成年者における輸血同意と拒否のフローチャート", "/files/pdf/flow_chart.pdf", False),
    ("他学会合同", "危機的出血への対応ガイドライン", "/files/pdf/kikitekiGL2.pdf", False),
    ("他学会合同", "危機的出血ガイドラインのポスター", "/files/pdf/0129kikitekiGL_poster_data.pdf", False),
    ("他学会合同", "患者プライバシー保護に関する指針（日本外科学会）", "http://www.jssoc.or.jp/other/info/privacy.html", True),
    ("他学会合同", "術中低血圧予測モニター使用指針", "/files/pdf/guideline_use_intraoperative_hypotension_prediction_monitor.pdf", False),
    ("他学会合同", "高齢者における術後せん妄の予防と治療のプラクティカルガイド", "/files/pdf/guideline_prevention_postoperative_delirium_elderly.pdf", False),
    ("他学会合同", "麻酔科領域における看護師の特定行為研修修了者の活用ガイド", "/files/pdf/guideline_specific_training_anesthesiology.pdf", False),
    ("他学会合同", "小児周術期ワクチンスケジュールに関するコンセンサスステートメント（日本小児科学会）", "https://www.jpeds.or.jp/society-activities/post-155658.html", True),

    # ── 医薬品ガイドライン（第4版） ──
    ("医薬品", "医薬品ガイドライン Ⅰ. 催眠鎮静薬", "/files/pdf/4_hypnosis_sedative.pdf", False),
    ("医薬品", "医薬品ガイドライン Ⅱ. 鎮痛薬・拮抗薬", "/files/pdf/4_analgesics_and_antagonists.pdf", False),
    ("医薬品", "医薬品ガイドライン Ⅲ. 静脈関連薬", "/files/pdf/4_venous_medicine.pdf", False),
    ("医薬品", "医薬品ガイドライン Ⅳ. 吸入麻酔薬", "/files/pdf/4_inhalation_anesthetic.pdf", False),
    ("医薬品", "医薬品ガイドライン Ⅴ. 局所麻酔薬", "/files/pdf/4_local_anesthetic.pdf", False),
    ("医薬品", "医薬品ガイドライン Ⅵ. 筋弛緩薬・拮抗薬", "/files/pdf/4_muscle_relaxant_antagonist.pdf", False),
    ("医薬品", "医薬品ガイドライン Ⅶ. 輸液・電解質液", "/files/pdf/4_infusion_electrolyte_solution.pdf", False),
    ("医薬品", "医薬品ガイドライン Ⅷ. 循環作動薬", "/files/pdf/4_circulating_agonist.pdf", False),
    ("医薬品", "医薬品ガイドライン Ⅸ. 産科麻酔薬", "/files/pdf/4_obstetric_anesthetic.pdf", False),
    ("医薬品", "医薬品ガイドライン Ⅹ. 小児麻酔薬", "/files/pdf/4_pediatric_anesthetics.pdf", False),
    ("医薬品", "医薬品ガイドライン Ⅺ. ペイン", "/files/pdf/4_pain_medicine.pdf", False),
    ("医薬品", "医薬品ガイドライン Ⅻ. その他", "/files/pdf/4_other_medicine.pdf", False),

    # ── その他 ──
    ("その他", "臨床研究実施と公表に必要な倫理事項", "/files/pdf/ethics_matters_necessary_publication.pdf", False),
    ("その他", "多数傷病者事故への院内対応手引き", "/files/pdf/in_hospital_guidance.pdf", False),
]

CATEGORY_ORDER = [
    "教育", "本学会制定ガイドライン", "プラクティカルガイド",
    "救急救命士マニュアル", "他学会合同", "医薬品", "その他",
]


def main():
    os.makedirs(PDF_DIR, exist_ok=True)
    os.makedirs(DATA_DIR, exist_ok=True)

    manifest = []
    seen_files = set()
    failures = []

    for i, (cat, title, path, external) in enumerate(ITEMS):
        entry = {
            "id": f"g{i:03d}",
            "title": title,
            "category": cat,
            "external": external,
        }
        if external:
            entry["url"] = path
        else:
            url = BASE + path
            fname = os.path.basename(path)
            assert fname not in seen_files, f"duplicate filename: {fname}"
            seen_files.add(fname)
            entry["url"] = url
            entry["file"] = fname
            dest = os.path.join(PDF_DIR, fname)
            if not (os.path.exists(dest) and os.path.getsize(dest) > 1000):
                r = subprocess.run(
                    ["curl", "-sL", "--fail", "--retry", "2",
                     "-A", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
                     url, "-o", dest],
                )
                if r.returncode != 0:
                    failures.append((title, url, f"curl exit {r.returncode}"))
                    manifest.append(entry)
                    continue
            with open(dest, "rb") as f:
                head = f.read(5)
            if head != b"%PDF-":
                failures.append((title, url, f"not a PDF (head={head!r})"))
                os.remove(dest)
            else:
                entry["size"] = os.path.getsize(dest)
        manifest.append(entry)

    out = {
        "source": "https://anesth.or.jp/users/person/guide_line",
        "fetched": "2026-06-10",
        "categories": CATEGORY_ORDER,
        "items": manifest,
    }
    with open(os.path.join(DATA_DIR, "guidelines.json"), "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, indent=1)

    n_pdf = sum(1 for e in manifest if not e["external"])
    total = sum(e.get("size", 0) for e in manifest)
    print(f"items: {len(manifest)} (pdf: {n_pdf}, external: {len(manifest) - n_pdf})")
    print(f"total size: {total / 1024 / 1024:.1f} MB")
    if failures:
        print("FAILURES:")
        for t, u, why in failures:
            print(f"  {t}: {u} -> {why}")
        sys.exit(1)
    print("all downloads OK")


if __name__ == "__main__":
    main()
