use pyo3::{
    prelude::*,
    types::{IntoPyDict, PyModule},
    exceptions,
};

// TODO: change this accordingly
use crate::app::utils::scrapers;

pub fn generate(quiz_source: String) -> PyResult<String> {
    pyo3::prepare_freethreaded_python();
    Python::with_gil(|py| {

        let quiz_generator = PyModule::from_code(
            py,
            include_str!("python/quiz_generator.py"),
            "quiz_generator.py",
            "quiz_generator",
        )?;

        let generated_quiz: String = quiz_generator
        .getattr("generate_quiz")?
        .call((quiz_source,), None)?
        .extract()?;

        // return JSON string
        Ok(generated_quiz)
    })
}