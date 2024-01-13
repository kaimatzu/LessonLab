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

pub fn regenerate_lesson_stream(content_to_regenerate: String, additional_instructions: String, index_path: String) -> PyResult<String> {
    pyo3::prepare_freethreaded_python();
    Python::with_gil(|py| {

        let lesson_generator = PyModule::from_code(
            py,
            include_str!("python/lesson_generator.py"),
            "lesson_generator.py",
            "lesson_generator",
        )?;

        if content_to_regenerate.is_empty(){
            let generated_lesson: String = lesson_generator
            .getattr("rust_callback_continue_lesson")?
            .call((additional_instructions, index_path), None)?
            .extract()?;

            Ok(generated_lesson)
        }
        else{
            let generated_lesson: String = lesson_generator
            .getattr("rust_callback_regenerate_lesson")?
            .call((content_to_regenerate, additional_instructions, index_path), None)?
            .extract()?;

            Ok(generated_lesson)
        }
    })
}
