pub mod menu_data_handlers {
    use http::StatusCode;
    use crate::app::global_objects::lessons_data_object::LessonsDataObject;
    use crate::app::settings::settings_data_object::SettingsDataObject;
    use crate::bridge::{RustOperation, RustRequest, RustResponse, RustSignal};
    use crate::messages::entry::menu::menu::{MenuModel, LessonModel, QuizModel, QuestionModel};
    use crate::messages::entry::upload::uploaded_content;
    use std::fs::File;
    use std::io::Read;
    use prost::Message;

    use tokio_with_wasm::tokio;
    use crate::app::entry::menu::menu_data_object::{MenuDataObject, Root};

    pub async fn handle_menu_content_loading(rust_request: RustRequest,
        menu_data_object: &mut tokio::sync::MutexGuard<'_, MenuDataObject>,
        settings_data_object: &mut tokio::sync::MutexGuard<'_, SettingsDataObject>) -> RustResponse {
        use crate::messages::entry::menu::menu::{ReadRequest, ReadResponse};
    
        match rust_request.operation {
            RustOperation::Create => RustResponse::default(),

            // RustOperation::Create => {
            //     let message_bytes: = rust_request.message.unwrap();
            //     let request_message: = CreateRequest::decode(message_bytes.as_slice()).unwrap();
            //     
            //     let _ = request_message;
            //     
            //     let mut file_path = settings_data_object.save_directory.clone();
            //     file_path.push_str("\\confing.json");
            
            // },

            RustOperation::Read => {
                // Debug purposes. Just to check if the uploaded files are stored in main().
                let message_bytes = rust_request.message.unwrap();
                let request_message = ReadRequest::decode(message_bytes.as_slice()).unwrap();
    
                let _ = request_message;

                let mut file_path = settings_data_object.save_directory.clone();
                file_path.push_str("\\config.json");

                let temp_menu_data_object = load_menu_data_from_file(file_path.as_str());
                menu_data_object.lessons_data_object = temp_menu_data_object.lessons_data_object;
                menu_data_object.quizzes_data_object = temp_menu_data_object.quizzes_data_object; 

                let response_message = ReadResponse {
                    menu_model: serialize_menu_model(menu_data_object)
                };
    
                RustResponse {
                    successful: true,
                    message: Some(response_message.encode_to_vec()),
                    blob: None,
                }
            },
            RustOperation::Update => RustResponse::default(),
            RustOperation::Delete => RustResponse::default(),
        }
    }

    fn serialize_menu_model(menu_data_object: &mut tokio::sync::MutexGuard<'_, MenuDataObject>) -> Option<MenuModel> {
        // Your logic to create a MenuModel
        let mut lessons: Vec<LessonModel> = Vec::new();
        for lesson in menu_data_object.lessons_data_object.lessons.clone() {
            let mut lesson_model: LessonModel = LessonModel::default();
            lesson_model.title = lesson.title;
            // Need to load content form target. Use a file opener
            lesson_model.location = lesson.target_path;
            lessons.push(lesson_model);
        }

        let mut quizzes: Vec<QuizModel> = Vec::new();
        for quiz in menu_data_object.quizzes_data_object.quizzes.clone() {
            let mut quiz_model: QuizModel = QuizModel::default();
            quiz_model.title = quiz.title;
            quiz_model.location = quiz.target_path;

            
            quizzes.push(quiz_model);
            // quiz_model.questions = quiz.questions;
            // quizzes.append(quiz_model);
        }

        let menu_model = MenuModel {
            lessons: lessons,
            quizzes: quizzes,
        };
    
        // Use Some to wrap the MenuModel in an Option
        Some(menu_model)
    }

    fn load_menu_data_from_file(file_path: &str) -> MenuDataObject {
        // Open the file
        let mut file = File::open(file_path).expect("Failed to open file");
    
        // Read the file content into a string
        let mut json_content = String::new();
        file.read_to_string(&mut json_content)
            .expect("Failed to read file content");
    
        // Deserialize the JSON content into a MenuDataObject
        let root: Root = serde_json::from_str(&json_content).expect("Failed to deserialize JSON");

        let menu_data: MenuDataObject = root.menu_data_object;
    
        menu_data
    }
}