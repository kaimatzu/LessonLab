from dotenv import load_dotenv
import os
import openai

def generate_lesson(source):
    load_dotenv()

    openai.api_key = os.getenv("API_KEY")

    prompt = "Can you make a markdown format lesson based on this source: " + source

	# TODO: https://app.clickup.com/t/86ctyuedm make OpenAI focus on a particular subject right now it's not focusing on a topic given in the "focus topic" specification

    completion = openai.ChatCompletion.create(
    model="gpt-3.5-turbo",
    messages=[
        {"role": "system", "content": "You are a college teacher."},
        {"role": "user", "content": prompt}
        ]
    )
    reply = completion['choices'][0]['message']['content']
    return reply