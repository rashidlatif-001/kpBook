import os
import sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import fitz
from PIL import Image, ImageDraw, ImageFont
from scripts.pdf_extractor import TextbookExtractionEngine

def test_ocr_extraction():
    os.makedirs('scripts', exist_ok=True)
    img_path = 'scripts/test_scanned_page.png'
    scanned_pdf_path = 'scripts/test_scanned_book.pdf'

    # 1. Create pure bitmap image
    img = Image.new('RGB', (800, 1000), color=(255, 255, 255))
    d = ImageDraw.Draw(img)
    d.text((50, 50), "UNIT 3 DYNAMICS", fill=(0, 0, 0))
    d.text((50, 120), "3.1 Force and Momentum", fill=(0, 0, 0))
    d.text((50, 180), "Definition: Force is an agent that produces or tends to produce motion.", fill=(0, 0, 0))
    d.text((50, 240), "Newton second law states that F = m * a.", fill=(0, 0, 0))
    img.save(img_path)

    # 2. Insert image into empty PDF (no text stream, scanned document)
    doc = fitz.open()
    rect = fitz.Rect(0, 0, 800, 1000)
    pdf_page = doc.new_page(width=800, height=1000)
    pdf_page.insert_image(rect, filename=img_path)
    doc.save(scanned_pdf_path)
    doc.close()

    print(f"Created scanned PDF: {scanned_pdf_path}")

    # 3. Test extraction with Tesseract OCR fallback
    engine = TextbookExtractionEngine()
    inspection = engine.inspect_pdf(scanned_pdf_path)
    print("Inspection result:", inspection)
    assert inspection['is_scanned'] == True, "Should detect PDF as scanned"

    extraction = engine.extract_text_and_layout(scanned_pdf_path)
    print(f"Detected chapters count: {len(extraction['chapters'])}")
    assert len(extraction['chapters']) > 0, "Should detect at least 1 chapter via OCR"

    ch = extraction['chapters'][0]
    print(f"Chapter Title: {ch['title']}")
    print(f"Topics Count: {len(ch['topics'])}")
    assert len(ch['topics']) > 0, "Should detect topic via OCR"

    topic = ch['topics'][0]
    print(f"Topic Title: {topic['title']}")
    print(f"Content blocks: {len(topic['content_blocks'])}")
    for blk in topic['content_blocks']:
        print(f" - [{blk['type']}] {blk['content']}")

    print("\n>>> OCR VERIFICATION PASSED SUCCESSFULLY! <<<")

if __name__ == '__main__':
    test_ocr_extraction()
