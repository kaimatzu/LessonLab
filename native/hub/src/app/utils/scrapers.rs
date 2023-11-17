use pyo3::{
    prelude::*,
    types::{IntoPyDict, PyModule},
};

pub fn scrape_pdf(file: String) -> PyResult<String> {
    pyo3::prepare_freethreaded_python();
    Python::with_gil(|py| {
        let scraper = PyModule::from_code(
            py,
            include_str!("python/pdf_scraper.py"),
            "pdf_scraper.py",
            "scrapers",
        )?;

        let lesson_source: String = scraper.getattr("scrape")?.call((file,), None)?.extract()?;
        Ok(lesson_source)
    })
}

pub fn scrape_url(url: String) -> PyResult<String> {
    pyo3::prepare_freethreaded_python();
    Python::with_gil(|py| {
        let scraper = PyModule::from_code(
            py,
            include_str!("python/url_scraper.py"),
            "url_scraper.py",
            "scrapers",
        )?;

        let lesson_source: String = scraper.getattr("scrape")?.call((url,), None)?.extract()?;

        Ok(lesson_source)
    })
}

pub fn validate_url(scraped_url: String) -> PyResult<bool> {
    pyo3::prepare_freethreaded_python();
    Python::with_gil(|py| {
        let check = PyModule::from_code(
            py,
            include_str!("python/validate_url.py"),
            "scraper.py",
            "scrapers",
        )?;

        let protection: bool = check
            .getattr("check_availability")?
            .call((scraped_url,), None)?
            .extract()?;

        Ok(protection)
    })
}