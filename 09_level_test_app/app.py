import streamlit as st
import json
import time
from openai import OpenAI
from prompts import SYSTEM_PROMPT_QUIZ, SYSTEM_PROMPT_ANALYSIS

# 1. 페이지 초기 설정
st.set_page_config(page_title="AI IT 역량 테스트 Pro (Mini)", layout="centered")

# --- [세션 상태 초기화] ---
if "step" not in st.session_state:
    st.session_state.step = "설정"
    st.session_state.quiz_data = []
    st.session_state.user_answers = {}
    st.session_state.is_guessed = {}
    st.session_state.start_time = None
    st.session_state.total_time = 0
    st.session_state.category = ""
    st.session_state.history = []     
    st.session_state.ai_analysis = "" 

# --- [사이드바 구성] ---
with st.sidebar:
    st.title("⚙️ 설정 및 기록")
    user_api_key = st.text_input("OpenAI API Key", type="password")
    
    st.write("---")
    st.info("💡 현재 **gpt-4o-mini** 모델을 사용하여 빠르고 저렴하게 테스트를 진행합니다.")
    
    st.write("---")
    theme = st.radio("🎨 배경 테마", ["기본 모드", "소프트 블루", "다크 그레이"])
    if theme == "소프트 블루":
        st.markdown("<style>.stApp { background-color: #f0f2f6; }</style>", unsafe_allow_html=True)
    elif theme == "다크 그레이":
        st.markdown("<style>.stApp { background-color: #262730; color: white; }</style>", unsafe_allow_html=True)

    st.write("---")
    st.subheader("📜 테스트 기록")
    if not st.session_state.history:
        st.caption("기록이 없습니다.")
    else:
        for idx, record in enumerate(reversed(st.session_state.history)):
            r_label = f"[{record.get('date','N/A')}] {record.get('category','')} ({record.get('score',0)}점)"
            if st.button(r_label, key=f"h_btn_{idx}"):
                st.session_state.update({
                    "quiz_data": record['quiz_data'],
                    "user_answers": record['user_answers'],
                    "is_guessed": record['is_guessed'],
                    "total_time": record['total_time'],
                    "category": record['category'],
                    "ai_analysis": record['ai_analysis'],
                    "step": "결과"
                })
                st.rerun()

# --- [Step 1: 설정 화면] ---
if st.session_state.step == "설정":
    st.title("🚀 Full-Stack AI 레벨 테스트")
    category = st.selectbox("종목 선택", ["Python", "SQL", "Numpy/Pandas", "Django", "ML/DL", "NLP", "LLM/RAG", "DevOps"])
    count = st.number_input("문제 수", 5, 20, 5)

    if st.button("테스트 시작"):
        if not user_api_key:
            st.error("사이드바에서 API Key를 입력하세요!")
        else:
            try:
                client = OpenAI(api_key=user_api_key)
                with st.spinner("문제를 빛의 속도로 생성 중..."):
                    response = client.chat.completions.create(
                        model="gpt-4o-mini",
                        messages=[{"role": "system", "content": SYSTEM_PROMPT_QUIZ.format(category=category, num_questions=count)}],
                        response_format={"type": "json_object"}
                    )
                    res_data = json.loads(response.choices[0].message.content)
                    st.session_state.quiz_data = res_data.get("questions", [])
                    st.session_state.category = category
                    st.session_state.ai_analysis = ""
                    st.session_state.step = "테스트"
                    st.session_state.start_time = time.time()
                    st.rerun()
            except Exception as e:
                st.error(f"오류: {e}")

# --- [Step 2: 테스트 화면] ---
elif st.session_state.step == "테스트":
    st.title(f"📝 {st.session_state.category} Test")
    with st.form("quiz_form"):
        for i, q in enumerate(st.session_state.quiz_data):
            st.markdown(f"### Q{i+1}. {q['question']}")
            ans = st.radio("정답 선택", range(len(q['options'])), format_func=lambda x: q['options'][x], key=f"ans_{i}")
            guessed = st.checkbox("💡 찍었습니다 (모름)", key=f"guess_{i}")
            st.session_state.user_answers[i] = ans
            st.session_state.is_guessed[i] = guessed
            st.write("---")
        
        if st.form_submit_button("최종 제출 및 레벨 확인"):
            st.session_state.total_time = time.time() - st.session_state.start_time
            st.session_state.step = "결과"
            st.rerun()

# --- [Step 3: 결과 화면] ---
elif st.session_state.step == "결과":
    st.title("📊 분석 결과")
    
    correct_count = 0
    analysis_list = []
    for i, q in enumerate(st.session_state.quiz_data):
        user_choice = st.session_state.user_answers.get(i)
        is_guessed = st.session_state.is_guessed.get(i)
        is_correct = (user_choice == q['answer_index']) and not is_guessed
        if is_correct: correct_count += 1
        status = "✅ 정답" if is_correct else ("🤔 찍음" if is_guessed else "❌ 오답")
        analysis_list.append({"id": i+1, "status": status, "q": q, "is_correct": is_correct})
            
    st.subheader(f"결과: {correct_count} / {len(st.session_state.quiz_data)} | 소요시간: {int(st.session_state.total_time)}초")

    if user_api_key and not st.session_state.ai_analysis:
        client = OpenAI(api_key=user_api_key)
        with st.spinner("AI 멘토가 분석 중..."):
            try:
                # 틀린 문제 요약 전달
                brief_data = [{"q": a['q']['question'], "ans": a['status']} for a in analysis_list if not a['is_correct']]
                
                res = client.chat.completions.create(
                    model="gpt-4o-mini",
                    messages=[{"role": "system", "content": SYSTEM_PROMPT_ANALYSIS.format(
                        category=st.session_state.category, score=correct_count, total=len(st.session_state.quiz_data), 
                        analysis_data=json.dumps({"avg_time": st.session_state.total_time/len(st.session_state.quiz_data), "wrong_info": brief_data}, ensure_ascii=False)
                    )}]
                )
                st.session_state.ai_analysis = res.choices[0].message.content
                
                # 히스토리 저장
                st.session_state.history.append({
                    "date": time.strftime("%m/%d %H:%M"),
                    "category": st.session_state.category,
                    "score": correct_count,
                    "quiz_data": st.session_state.quiz_data,
                    "user_answers": st.session_state.user_answers,
                    "is_guessed": st.session_state.is_guessed,
                    "total_time": st.session_state.total_time,
                    "ai_analysis": st.session_state.ai_analysis
                })
            except:
                st.session_state.ai_analysis = "분석 중 오류가 발생했습니다."

    st.markdown("---")
    st.markdown(st.session_state.ai_analysis)

    with st.expander("🧐 문항별 해설 보기"):
        for item in analysis_list:
            st.markdown(f"**Q{item['id']}. {item['status']}**")
            st.info(f"해설: {item['q'].get('explanation', '')}")

    if st.button("🏠 홈으로 이동"):
        for key in ["quiz_data", "user_answers", "is_guessed", "ai_analysis", "category", "total_time"]:
            if key in st.session_state: del st.session_state[key]
        st.session_state.step = "설정"
        st.rerun()