// Данные матчей
const matches = [
  {
    date: '2026-02-20',
    time: '19:00',
    team1: 'Авангард',
    team2: 'Металлург Мг',
    arena: 'G-Drive Арена, Омск',
    score: '3 : 2'
  },
  {
    date: '2026-02-21',
    time: '17:30',
    team1: 'СКА',
    team2: 'ЦСКА',
    arena: 'СКА Арена, Санкт-Петербург',
    score: '2 : 4'
  },
    {
    date: '2026-03-25',
    time: '17:30',
    team1: 'СПАРТАК',
    team2: 'ТОРПЕДО',
    arena: 'СКА Арена, Санкт-Петербург',
    score: '2 : 4'
  },
  {
    date: '2026-03-25',
    time: '17:30',
    team1: 'СОЧИ',
    team2: 'АК БАРС',
    arena: 'СКА Арена, Санкт-Петербург',
    score: '2 : 4'
  },
  {
    date: '2026-03-25',
    time: '17:30',
    team1: 'САЛАВАТ',
    team2: 'АК БАРС',
    arena: 'ТОРПЕДО, НИЖНИЙ НОВГОРОД',
    score: '2 : 4'
  }
  // Добавьте остальные матчи
];

// DOM-элементы
const matchesList = document.getElementById('matches-list');
const dateFilter = document.getElementById('date-filter');
const teamFilter = document.getElementById('team-filter');
const clearFiltersBtn = document.getElementById('clear-filters');

// Функция рендеринга матчей
function renderMatches(filteredMatches) {
  matchesList.innerHTML = '';
  if (filteredMatches.length === 0) {
    matchesList.innerHTML = '<li><p>Матчи не найдены.</p></li>';
    return;
  }

  filteredMatches.forEach(match => {
    const li = document.createElement('li');
    li.innerHTML = `
      <div class="match-info">
        <h3>${match.team1} — ${match.team2}</h3>
        <p>${match.date} | ${match.time} | ${match.arena}</p>
      </div>
      <div class="match-score">${match.score}</div>
    `;
    matchesList.appendChild(li);
  });
}

// Фильтрация матчей
function filterMatches() {
  const selectedDate = dateFilter.value;
  const teamQuery = teamFilter.value.toLowerCase();

  const filtered = matches.filter(match => {
    if (selectedDate && match.date !== selectedDate) return false;
    if (teamQuery &&
        !match.team1.toLowerCase().includes(teamQuery) &&
        !match.team2.toLowerCase().includes(teamQuery)) {
      return false;
    }
    return true;
  });

  renderMatches(filtered);
}

// Инициализация
document.addEventListener('DOMContentLoaded', () => {
  renderMatches(matches); // Показываем все матчи при загрузке
  
  // Обработчики событий
  dateFilter.addEventListener('change', filterMatches);
  teamFilter.addEventListener('input', filterMatches);
  clearFiltersBtn.addEventListener('click', () => {
    dateFilter.value = '';
    teamFilter.value = '';
    renderMatches(matches);
  });
});
