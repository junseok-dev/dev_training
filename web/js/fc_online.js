document.addEventListener('DOMContentLoaded', () => {
    // 게임 시작 버튼 클릭 이벤트
    const startBtn = document.querySelector('.btn-game-start');
    startBtn.addEventListener('click', () => {
        alert("게임 실행을 위해 런처를 확인 중입니다...");
    });

    // 로그인 클릭
    const loginLink = document.getElementById('login-link');
    loginLink.addEventListener('click', (e) => {
        e.preventDefault();
        const id = prompt("넥슨 아이디를 입력하세요:");
        if(id) {
            loginLink.innerHTML = `<i class="fas fa-user"></i> ${id}님`;
            loginLink.style.color = "#f5c518";
        }
    });

    // 카드 호버 효과 애니메이션 (간단)
    const cards = document.querySelectorAll('.grid-card');
    cards.forEach(card => {
        card.addEventListener('mouseenter', () => {
            card.style.filter = "brightness(1.1)";
        });
        card.addEventListener('mouseleave', () => {
            card.style.filter = "brightness(1.0)";
        });
    });
});