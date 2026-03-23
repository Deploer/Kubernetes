// Данные матчей (пример)
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
    date: '2026-02-22',
    time: '15:00',
    team1: 'Локомотив',
    team2: 'Динамо Мн',
    arena: 'Арена-2000, Ярославль',
    score: '5 : 1'
  },
  {
    date: '2026-02-23',
    time: '19:30',
    team1: 'Салават Юлаев',
    team2: 'Ак Барс',
    arena: 'Уфа-Арена, Уфа',
    score: '1 : 3'
  },
  {
    date: '2026-02-24',
    time: '18:00',
    team1: 'Трактор',
    team2: 'Сибирь',
    arena: 'Арена Трактор, Челябинск',
    score: '4 : 2'
  }
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
    // Фильтрация по дате
    if (selectedDate && match.date !== selectedDate) return false;

    // Фильтрация по команде
    if (teamQuery &&
        !match.team1.toLowerCase().includes(teamQuery) &&
        !match.team2.toLowerCase().includes(teamQuery)) {
      return false;
    }

    return true;
  });

  renderMatches(filtered);