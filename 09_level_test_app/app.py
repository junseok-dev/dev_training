import streamlit as st
import os
import json
from openai import OpenAI
from dotenv import load_dotenv
from prompts import SYSTEM_PROMPT_QUIZ, SYSTEM_PROMPT_ANALYSIS

# 1. .env 파일 로드
load_dotenv()
api_key = os.getenv("OPENAI_API_KEY")

# 초기 설정
st.set_page_config(page_title="AI 역량 테스트", layout="centered")

# API 키 확인 및 클라이언트 초기화
if not api_key:
    st.error(".env 파일에 OPENAI_API_KEY가 설정되어 있지 않습니다.")
    st.stop()

client = OpenAI(api_key=api_key)

# 세션 상태 초기화
if "step" not in st.session_state:
    st.session_state.step = "설정"
    st.session_state.quiz_data = []
    st.session_state.user_answers = {}

# --- [설정 화면] ---
if st.session_state.step == "설정":
    st.title("🚀 Full-Stack AI 역량 테스트")
    # 준석님이 관심 있는 스택들로 구성
    category = st.selectbox("카테고리 선택", [
        "Python", "SQL", "Numpy/Pandas", "Django", 
        "ML/DL", "NLP", "LLM/RAG", "DevOps"
    ])
    level = st.slider("난이도 (1: 기초 ~ 5: 전문가)", 1, 5, 3)
    count = st.number_input("문제 수 (10~50)", 10, 50, 10)

    if st.button("테스트 시작"):
        with st.spinner("AI가 문제를 생성 중입니다..."):
            response = client.chat.completions.create(
                model="gpt-4o",
                messages=[{"role": "system", "content": SYSTEM_PROMPT_QUIZ.format(
                    category=category, level=level, num_questions=count)}],
                response_format={"type": "json_object"}
            )
            st.session_state.quiz_data = json.loads(response.choices[0].message.content)
            st.session_state.category = category
            st.session_state.step = "테스트"
            st.rerun()

# --- [테스트 화면] --- (이전과 동일)
elif st.session_state.step == "테스트":
    st.title(f"📝 {st.session_state.category} Test")
    # ... (중략: 이전 코드와 동일하게 문항 출력 로직 작성)
    # 최종 제출 버튼 클릭 시 st.session_state.step = "결과"로 변경