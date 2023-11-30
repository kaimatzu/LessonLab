use pyo3::{
    prelude::*,
    types::{IntoPyDict, PyModule},
};

pub fn scrape_pdf(file: String) -> PyResult<String> {
    pyo3::prepare_freethreaded_python();
    Python::with_gil(|py| {
        let scraper = PyModule::from_code(
            py,
            include_str!("python/scraper.py"),
            "scraper.py",
            "scrapers",
        )?;
        
        let lesson_source: String = scraper
        .getattr("scrape_pdf")?
        .call((file,), None)?
        .extract()?;

        Ok(lesson_source)
    })
}

pub fn scrape_url(url: String) -> PyResult<String> {
    pyo3::prepare_freethreaded_python();
    Python::with_gil(|py| {
        let scraper = PyModule::from_code(
            py,
            include_str!("python/scraper.py"),
            "scraper.py",
            "scrapers",
        )?;

        let lesson_source: String = scraper
        .getattr("scrape_url")?
        .call((url,), None)?
        .extract()?;

        Ok(lesson_source)
    })
}

// pub fn validate_url(scraped_url: String) -> PyResult<bool> {
//     pyo3::prepare_freethreaded_python();
//     Python::with_gil(|py| {
//         let check = PyModule::from_code(
//             py,
//             include_str!("python/validate_url.py"),
//             "validate_url.py",
//             "scrapers",
//         )?;

//         let protection: bool = check
//             .getattr("check_availability")?
//             .call((scraped_url,), None)?
//             .extract()?;

//         Ok(protection)
//     })
// }

pub fn scrape_txt(file: String) -> PyResult<String> {
    pyo3::prepare_freethreaded_python();
    Python::with_gil(|py| {
        let check = PyModule::from_code(
            py,
            include_str!("python/scraper.py"),
            "scraper.py",
            "scrapers",
        )?;

        let lesson_source: String = check
            .getattr("scrape_txt")?
            .call((file,), None)?
            .extract()?;

        Ok(lesson_source)
    })
}

pub fn scrape_docx(file: String) -> PyResult<String> {
    pyo3::prepare_freethreaded_python();
    Python::with_gil(|py| {
        let check = PyModule::from_code(
            py,
            include_str!("python/scraper.py"),
            "scraper.py",
            "scrapers",
        )?;

        let lesson_source: String = check
            .getattr("scrape_docx")?
            .call((file,), None)?
            .extract()?;

        Ok(lesson_source)
    })
}

pub fn scrape_pptx(file: String) -> PyResult<String> {
    pyo3::prepare_freethreaded_python();
    Python::with_gil(|py| {
        let check = PyModule::from_code(
            py,
            include_str!("python/scraper.py"),
            "scraper.py",
            "scrapers",
        )?;

        let lesson_source: String = check
            .getattr("scrape_pptx")?
            .call((file,), None)?
            .extract()?;

        Ok(lesson_source)
    })
}

pub fn scrape_csv(file: String) -> PyResult<String> {
    pyo3::prepare_freethreaded_python();
    Python::with_gil(|py| {
        let check = PyModule::from_code(
            py,
            include_str!("python/scraper.py"),
            "scraper.py",
            "scrapers",
        )?;

        let lesson_source: String = check
            .getattr("scrape_csv")?
            .call((file,), None)?
            .extract()?;

        Ok(lesson_source)
    })
}

pub fn scrape_xlsx(file: String) -> PyResult<String> {
    pyo3::prepare_freethreaded_python();
    Python::with_gil(|py| {
        let check = PyModule::from_code(
            py,
            include_str!("python/scraper.py"),
            "scraper.py",
            "scrapers",
        )?;

        let lesson_source: String = check
            .getattr("scrape_xlsx")?
            .call((file,), None)?
            .extract()?;

        Ok(lesson_source)
    })
}