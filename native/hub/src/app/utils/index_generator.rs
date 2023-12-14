use pyo3::{
    prelude::*,
    types::{IntoPyDict, PyModule},
    exceptions,
};

pub fn generate_index(files: Vec<String>, urls: Vec<String>, storage_path: String) -> PyResult<String> {
    pyo3::prepare_freethreaded_python();
    Python::with_gil(|py| {

        let index_generator = PyModule::from_code(
            py,
            include_str!("python/index_generator.py"),
            "index_generator.py",
            "index_generator",
        )?;

        let generated_index: String = index_generator
        .getattr("generate_index_from_docs")?
        .call((files, urls, storage_path), None)?
        .extract()?;

        Ok(generated_index)
    })
}