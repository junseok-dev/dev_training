import streamlit as st
import os
from datetime import datetime

# LangChain v0.3+ 표준 임포트
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

# 1. 페이지 설정
st.set_page_config(page_title="Live Python Mentor", page_icon="🦜", layout="wide")

# 2. 사이드바: API 키 설정, 테마, 글꼴 및 히스토리 관리
with st.sidebar:
    st.title("🔑 API 및 환경 설정")
    
    # 사용자 API Key 입력 (비밀번호 형식)
    user_api_key = st.text_input(
        "OpenAI API Key를 입력하세요", 
        type="password", 
        placeholder="sk-...",
        help="입력하신 키는 서버에 저장되지 않으며 세션이 종료되면 파기됩니다."
    )
    
    st.divider()
    st.title("🌓 테마 및 디자인")
    theme_choice = st.radio("앱 테마 선택", ["Dark", "Light"], index=0, horizontal=True)
    font_size = st.slider("글꼴 크기 설정 (px)", 12, 30, 16)
    
    st.divider()
    st.title("📜 학습 로그")
    if st.button("🗑️ 기록 초기화", use_container_width=True):
        st.session_state.history = []
        st.rerun()
    
    st.divider()
    if 'history' not in st.session_state:
        st.session_state.history = []
        
    for entry in reversed(st.session_state.history):
        with st.expander(f"🕒 {entry['time']} - {entry['title']}"):
            st.code(entry['code'], language='python')
            if st.button("다시 보기", key=f"history_{entry['time']}"):
                st.session_state.current_analysis = entry['analysis']

# 3. 동적 테마 및 글꼴 크기 CSS 적용
if theme_choice == "Dark":
    bg_color, text_color, border_color, editor_bg = "#0d1117", "#c9d1d9", "#30363d", "#010409"
else:
    bg_color, text_color, border_color, editor_bg = "#ffffff", "#1f2328", "#d0d7de", "#f6f8fa"

st.markdown(f"""
    <style>
    .stApp {{ background-color: {bg_color}; color: {text_color}; }}
    [data-testid="stSidebar"] {{ background-color: {'#161b22' if theme_choice == 'Dark' else '#f6f8fa'}; border-right: 1px solid {border_color}; }}
    .stTextArea textarea {{
        background-color: {editor_bg} !important;
        color: {text_color} !important;
        border: 1px solid {border_color} !important;
        font-family: 'Cascadia Code', 'Fira Code', monospace !important;
        font-size: {font_size}px !important;
        border-radius: 6px;
    }}
    .stMarkdown p, .stMarkdown li, .stMarkdown table {{
        font-size: {font_size}px !important;
        line-height: 1.6;
    }}
    .stButton button {{ border-radius: 6px; font-weight: 600; }}
    </style>
    """, unsafe_allow_html=True)

# 4. 메인 화면 레이아웃
st.title("🦜 LangChain을 활용한 라이브 파이썬 멘토링")
st.markdown(f"설정이 완료되었습니다. 현재 **{theme_choice} 모드** 환경입니다.")

col_editor, col_report = st.columns([1, 1], gap="large")

with col_editor:
    st.subheader("⌨️ 코드 에디터")
    user_input = st.text_area("코드 입력", height=500, label_visibility="collapsed", placeholder="분석할 파이썬 코드를 입력하세요.")
    analyze_click = st.button("🚀 실시간 심층 분석 시작", use_container_width=True, type="primary")

with col_report:
    st.subheader("🔍 실시간 분석 리포트")
    
    if analyze_click:
        if not user_api_key:
            st.error("⚠️ 사이드바에 OpenAI API Key를 먼저 입력해 주세요.")
        elif not user_input.strip():
            st.warning("분석할 코드를 입력해 주세요.")
        else:
            try:
                # 사용자가 입력한 키로 LLM 및 Chain 초기화
                llm = ChatOpenAI(
                    model="gpt-4o-mini", 
                    temperature=0, 
                    streaming=True, 
                    openai_api_key=user_api_key
                )

                prompt = ChatPromptTemplate.from_messages([
                    ("system", """
                    당신은 파이썬 코드를 정밀하게 분석하는 '라이브 멘토'입니다.
                    반드시 다음 구조로 답변하되, 특히 '심층 해설' 섹션을 상세히 작성하세요.
                    1. ✅ 교정된 코드 (최신 문법 적용)
                    2. 📊 라인별 변수 & 출력 추적 테이블
                    3. 🧠 [핵심] 줄 단위 심층 로직 해설 (비중 80% 이상)
                    4. 🖥️ 최종 실행 결과
                    """),
                    ("user", "{user_input}")
                ])

                chain = prompt | llm | StrOutputParser()

                with st.container(border=True):
                    # LangChain 스트리밍 실행
                    full_analysis = st.write_stream(chain.stream({"user_input": user_input}))
                    
                    # 히스토리 저장
                    now_str = datetime.now().strftime("%H:%M:%S")
                    first_line = user_input.strip().split('\n')[0][:25] + "..."
                    st.session_state.history.append({
                        "time": now_str, "title": first_line, "code": user_input, "analysis": full_analysis
                    })
                    st.balloons()
            
            except Exception as e:
                st.error(f"오류가 발생했습니다: {e}\nAPI Key가 유효한지 확인해 주세요.")
                
    elif 'current_analysis' in st.session_state:
        st.markdown(st.session_state.current_analysis)
    else:
        st.info("키 입력 후 버튼을 누르면 **심층 분석**이 시작됩니다.")

# 5. 하단 안내
st.divider()
st.caption("© 2026 Live Python Mentor - Powered by LangChain & OpenAI")