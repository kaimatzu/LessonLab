pub mod menu_data_handlers {
    use http::StatusCode;
    use crate::app::entry::upload::upload_sources_data_object::TextFile;
    use crate::app::global_objects::lessons_data_object::{LessonsDataObject, Lesson};
    use crate::app::global_objects::quizzes_data_object::{self, QuizzesDataObject};
    use crate::app::results::lesson_result_data_object::Sources;
    use crate::app::settings::settings_data_object::SettingsDataObject;
    use crate::bridge::{RustOperation, RustRequest, RustResponse, RustSignal};
    use crate::messages::entry::menu::menu::{MenuModel, LessonModel, QuizModel, QuestionModel};
    use crate::messages::entry::upload::uploaded_content;
    use std::fs::File;
    use std::io::Read;
    use prost::Message;

    use tokio_with_wasm::tokio;
    use crate::app::entry::menu::menu_data_object::{MenuDataObject, Root};

    pub async fn handle_lesson_crud(rust_request: RustRequest) -> RustResponse {
        use crate::messages::entry::menu::menu::{ReadRequest, ReadResponse};

        match rust_request.operation {
            RustOperation::Create => RustResponse::default(),
            RustOperation::Read => RustResponse::default(),
            RustOperation::Update => RustResponse::default(),
            RustOperation::Delete => RustResponse::default(),
        }
    }

    pub async fn handle_quiz_crud(rust_request: RustRequest) -> RustResponse {
        use crate::messages::entry::menu::menu::{ReadRequest, ReadResponse};

        match rust_request.operation {
            RustOperation::Create => RustResponse::default(),
            RustOperation::Read => RustResponse::default(),
            RustOperation::Update => RustResponse::default(),
            RustOperation::Delete => RustResponse::default(),
        }

    }

    /// Handles the CRUD for the data in Menu screen
    /// @see menu_connection_orchestrator.dart
    /// @see MenuConnectionOrchestrator
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

            // Loads data in the specified path in the sharedpreferences.json
            // using the metadata in config.json file
            // and the returned value of this function is passed to the MenuConnectionOrchestrator in Dart
            // @see menu_connection_orchestrator.dart
            RustOperation::Read => {
                // Debug purposes. Just to check if the uploaded files are stored in main().
                let message_bytes = rust_request.message.unwrap();
                let request_message = ReadRequest::decode(message_bytes.as_slice()).unwrap();
    
                let _ = request_message;

                // Get the save directory from settings
                let mut file_path = settings_data_object.save_directory.clone();
                file_path.push_str("\\config.json");

                // Get lesson and quiz data from saved files
                let temp_menu_data_object = load_menu_data_from_file(file_path.as_str());
                menu_data_object.lessons_data_object = temp_menu_data_object.lessons_data_object;
                menu_data_object.quizzes_data_object = temp_menu_data_object.quizzes_data_object; 

                // Create message
                let response_message = ReadResponse {
                    menu_model: serialize_menu_model(menu_data_object)
                };
    
                // Create rust response to send to dart
                RustResponse {
                    successful: true,
                    message: Some(response_message.encode_to_vec()),
                    blob: None,
                }
            },
            // RustOperation::Update => RustResponse::default(),
            // RustOperation::Delete => RustResponse::default(),
            RustOperation::Update => {
                /*
                    STEPS FOR `MenuModel` UPDATE VERSION

                    1. retrieve MenuModel data from Dart and item ID
                    2. Find file with ID
                    3. If exist => update
                        write the updated file
                       If not => create
                        write new file
                    4. write current MenuModel status in config.json
                        - erase the deleted entry in json
                        Regex to delete -> {"title": "<title>"*"sources":{*}*},
                 */
                let message_bytes = rust_request.message.unwrap();
                let request_message = ReadRequest::decode(message_bytes.as_slice()).unwrap();
    
                let _ = request_message;

                // Get the save directory from settings
                let mut file_path = settings_data_object.save_directory.clone();
                file_path.push_str("\\config.json");

                // Read lesson and quiz data from saved files
                let temp_menu_data_object = load_menu_data_from_file(file_path.as_str());
                menu_data_object.lessons_data_object = temp_menu_data_object.lessons_data_object;
                menu_data_object.quizzes_data_object = temp_menu_data_object.quizzes_data_object; 

                // STEPS FOR `LessonModel` UPDATE VERSION
                // Update lesson or quiz according to ID/filepath (TBD)
                // example -- menu_data_object.lessons.update(int id, LessonModel updatedModel);
                // - find the path of that file and update the contents in that directory
                // Update the actual file

                // If it fails to find the specified lesson/quiz create a entry
                // return 201
                
                // Update config.json (edit the updated item)
                // - Get the config.json text and edit the updated item
                // - Write again to config.json

                // Create message
                let response_message = ReadResponse {
                    menu_model: serialize_menu_model(menu_data_object)
                };
                // let response_message = UpdateResponse {
                //     status_code: 200,
                // };
    
                // Create rust response to send to dart
                RustResponse {
                    successful: true,
                    message: Some(response_message.encode_to_vec()),
                    blob: None,
                }
            },
            RustOperation::Delete => {
                let message_bytes = rust_request.message.unwrap();
                let request_message = ReadRequest::decode(message_bytes.as_slice()).unwrap();
    
                let _ = request_message;

                // Get the save directory from settings
                let mut file_path = settings_data_object.save_directory.clone();
                file_path.push_str("\\config.json");


                // Read lesson and quiz data from saved files
                let temp_menu_data_object = load_menu_data_from_file(file_path.as_str());
                menu_data_object.lessons_data_object = temp_menu_data_object.lessons_data_object;
                menu_data_object.quizzes_data_object = temp_menu_data_object.quizzes_data_object; 

                // --- STEPS ---
                // Delete lesson or quiz according to ID/filepath (TBD)
                // menu_data_object.lessons.delete(int id);
                // - find the path of that file and delete the directory

                // If it fails to find the specified lesson/quiz return error 404
                
                // Update config.json (erase the deleted item)
                // - get the config.json text and erase the deleted item
                // Delete the actual file

                // Create message
                let response_message = ReadResponse {
                    menu_model: serialize_menu_model(menu_data_object)
                };
    
                // Create rust response to send to dart
                RustResponse {
                    successful: true,
                    message: Some(response_message.encode_to_vec()),
                    blob: None,
                }
            },
        }
    }

    fn serialize_menu_model(menu_data_object: &mut tokio::sync::MutexGuard<'_, MenuDataObject>) -> Option<MenuModel> {
        // Logic to create a MenuModel
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

    fn deserialize_menu_model(menu_model: &mut tokio::sync::MutexGuard<'_, MenuModel>) -> Option<MenuDataObject>{

        let lessons: Vec<Lesson>;


        for lesson in menu_model.lessons.clone() {
            // TODO: Add sources to `MenuModel`
            let mut texts: Vec<TextFile>;

            for source in lesson.source.unwrap().texts {
                texts.push(TextFile {
                    title: source.title,
                    content: source.content,
                });
            }		

            let mut temp_lesson = Lesson {
                id: lesson.id,
                title: lesson.title.clone(),
                target_path: lesson.location.clone(),
                sources: Sources {
                    source_files: lesson.clone().source.unwrap().files,
                    source_urls: lesson.clone().source.unwrap().urls,
                    source_texts: texts,
                },
            };
            lessons.push(temp_lesson.clone());
        }


        let mdo = MenuDataObject {
            lessons_data_object: LessonsDataObject { lessons },
            quizzes_data_object: QuizzesDataObject { quizzes: todo!() },
        };

        Some(mdo)
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