const videos = [
    { title: "2026년형 초고속 웹 개발 가이드", author: "코딩 장인", views: "25만회", date: "2시간 전", thumb: "https://picsum.photos/seed/code/320/180" },
    { title: "세계에서 가장 아름다운 휴양지 TOP 10", author: "여행가이드", views: "120만회", date: "1일 전", thumb: "https://picsum.photos/seed/travel/320/180" },
    { title: "심야 라디오 - 비 오는 날 듣기 좋은 음악", author: "Lofi Girl", views: "3.4만회", date: "방금 전", thumb: "https://picsum.photos/seed/music/320/180" },
    { title: "10분 안에 끝내는 전신 운동", author: "홈트레이닝", views: "88만회", date: "1개월 전", thumb: "https://picsum.photos/seed/health/320/180" },
    { title: "자바스크립트의 비밀: 당신이 몰랐던 5가지", author: "JS 마스터", views: "12만회", date: "3일 전", thumb: "https://picsum.photos/seed/js/320/180" },
    { title: "오늘 점심 뭐 먹지? 간단 레시피", author: "쿠킹클래스", views: "50만회", date: "1주일 전", thumb: "https://picsum.photos/seed/cook/320/180" },
];

const videoGrid = document.getElementById('videoGrid');

// 비디오 렌더링
function renderVideos() {
    videoGrid.innerHTML = videos.map(video => `
        <div class="video-card">
            <img src="${video.thumb}" class="thumbnail" alt="thumbnail">
            <div class="details">
                <div class="channel-img"></div>
                <div class="info">
                    <h3>${video.title}</h3>
                    <p>${video.author}</p>
                    <p>조회수 ${video.views} • ${video.date}</p>
                </div>
            </div>
        </div>
    `).join('');
}

// 메뉴 아이콘 클릭 시 사이드바 토글 (간단 구현)
document.getElementById('menu-icon').addEventListener('click', () => {
    const sidebar = document.querySelector('.sidebar');
    const content = document.querySelector('.content');
    if (sidebar.style.display === 'none') {
        sidebar.style.display = 'block';
        content.style.marginLeft = '240px';
    } else {
        sidebar.style.display = 'none';
        content.style.marginLeft = '0';
    }
});

renderVideos();