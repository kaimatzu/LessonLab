use pyo3::{
    prelude::*,
    types::{IntoPyDict, PyModule},
    exceptions,
};

// TODO: change this accordingly
use crate::{app::utils::scrapers, messages::quiz::quiz_specifications};

pub fn generate(
    files: Vec<String>,
    urls: Vec<String>,
    index_path: String,
    quiz_specifications: Vec<String>) -> PyResult<String> {
    pyo3::prepare_freethreaded_python();
    Python::with_gil(|py| {

        let quiz_generator = PyModule::from_code(
            py,
            include_str!("python/quiz_generator.py"),
            "quiz_generator.py",
            "quiz_generator",
        )?;

        let generated_quiz: String = quiz_generator // this will return JSON
        .getattr("rust_callback")?
        .call((quiz_specifications, index_path, files, urls), None)?
        .extract()?;

        crate::debug_print!("{}", generated_quiz);

        // return JSON string
        Ok(generated_quiz)
    })
}