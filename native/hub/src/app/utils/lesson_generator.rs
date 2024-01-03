use pyo3::{
    prelude::*,
    types::{IntoPyDict, PyModule},
    exceptions,
};

// TODO: change this accordingly
use crate::app::utils::scrapers;

pub fn generate(lesson_source: String) -> PyResult<String> {
    pyo3::prepare_freethreaded_python();
    Python::with_gil(|py| {

        let lesson_generator = PyModule::from_code(
            py,
            include_str!("python/lesson_generator.py"),
            "lesson_generator.py",
            "lesson_generator",
        )?;

        let generated_lesson:String = lesson_generator
        .getattr("generate_lesson")?
        .call((lesson_source,), None)?
        .extract()?;

        Ok(generated_lesson)
    })
}

pub fn generate_lesson_stream() -> PyResult<String> {
    let lesson_source = match scrapers::scrape_pdf(String::from("C:/Users/karlj/OneDrive/Documents/Proxy Design Pattern Summary.pdf")) {
        Ok(source) => {
            println!("{}", source);
            println!("\nGenerated Lesson:_______________________________________________________________\n");
            source
        }
        Err(_) => return Err(PyErr::new::<exceptions::PyException, _>("Failed to scrape PDF")),
    };

    pyo3::prepare_freethreaded_python();
    Python::with_gil(|py| {

        let lesson_generator = PyModule::from_code(
            py,
            include_str!("python/lesson_generator.py"),
            "lesson_generator.py",
            "lesson_generator",
        )?;

        let generated_lesson: String = lesson_generator
        .getattr("generate_lesson_stream")?
        .call((lesson_source,), None)?
        .extract()?;

        Ok(generated_lesson)
    })
}
