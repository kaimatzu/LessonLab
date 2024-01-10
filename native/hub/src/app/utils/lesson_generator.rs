use pyo3::{
    prelude::*,
    types::{IntoPyDict, PyModule},
    exceptions,
};

// TODO:change this accordingly
use crate::app::utils::scrapers;

pub fn generate_lesson_stream(files: Vec<String>, urls: Vec<String>, index_path: String, lesson_specifications: Vec<String>) -> PyResult<String> {
    pyo3::prepare_freethreaded_python();
    Python::with_gil(|py| {

        let lesson_generator = PyModule::from_code(
            py,
            include_str!("python/lesson_generator.py"),
            "lesson_generator.py",
            "lesson_generator",
        )?;

        let generated_lesson: String = lesson_generator
        .getattr("rust_callback")?
        .call((lesson_specifications, index_path, files, urls), None)?
        .extract()?;

        Ok(generated_lesson)
    })
}
