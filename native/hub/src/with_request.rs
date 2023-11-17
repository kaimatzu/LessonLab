//! This module runs the corresponding function
//! when a `RustRequest` was received from Dart
//! and returns a `RustResponse`.

use crate::app::lesson::lesson_specifications_model::LessonSpecificationsModel;
use crate::bridge::{RustRequestUnique, RustResponse, RustResponseUnique};
use crate::messages;
use crate::app;

// use std::sync::{Arc, Mutex};
use tokio_with_wasm::tokio;
// use tokio::sync::Mutex;
use tokio_with_wasm::tokio::sync::{Mutex};
use std::sync::{Arc};
use app::entry::upload::upload_model::{UploadModel, TextFile};

pub async fn handle_request(request_unique: RustRequestUnique,
    upload_model: &mut tokio::sync::MutexGuard<'_, UploadModel>,
    lesson_specifications_model: &mut tokio::sync::MutexGuard<'_, LessonSpecificationsModel>) -> RustResponseUnique {
    // Get the request data from Dart.
    let rust_request = request_unique.request;
    let interaction_id = request_unique.id;

    // Run the function that handles the Rust resource.
    let rust_resource = rust_request.resource;
    let rust_response = match rust_resource {
        messages::entry::upload::uploaded_content::ID => { // Handle Uploaded File content
            app::entry::upload::upload_view_model::handle_uploaded_content(rust_request, upload_model).await
        }
        messages::lesson::lesson_specifications::ID => {
            app::lesson::lesson_specifications_view_model::handle_lesson_specifications(rust_request, lesson_specifications_model).await
        }
        _ => RustResponse::default(),
    };

    // Return the response to Dart.
    RustResponseUnique {
        id: interaction_id,
        response: rust_response,
    }
}
