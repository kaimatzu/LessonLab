import fitz

def scrape(src):
    fileName = src
    pdf_document = fitz.open(fileName)
    markdown_text = ""
    for page_number in range(pdf_document.page_count):
        page = pdf_document[page_number]
        page_text = page.get_text()
        markdown_text += page_text
    return markdown_text
