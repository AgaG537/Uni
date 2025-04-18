const words = ["COMPUTER", "PROGRAMMING", "JAVASCRIPT", "DEVELOPER", "FUNCTION", "VARIABLE", "DEBUGGING"];
const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("");

const wordContainer = document.getElementById("word-container");
const lettersContainer = document.getElementById("letters-container");
const messageDiv = document.getElementById("message");
const canvas = document.getElementById("hangman-canvas");
const ctx = canvas.getContext("2d");

const startScreen = document.getElementById("start-screen");
const gameContainer = document.getElementById("game-container");

const startBtn = document.getElementById("start-btn");
const restartBtn = document.getElementById("restart-btn");
const cancelBtn = document.getElementById("cancel-btn");
const backBtn = document.getElementById("back-btn");

let selectedWord = "";
let displayedWord = [];
let mistakes = 0;
const maxMistakes = 6;
let gameActive = false;

function initGame() {
  selectedWord = words[Math.floor(Math.random() * words.length)];
  displayedWord = Array(selectedWord.length).fill("");
  mistakes = 0;
  gameActive = true;

  messageDiv.textContent = "";
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  drawHangman();
  renderWord();
  renderAlphabet();
  updateButtons();
  saveGameState();
}

function renderWord() {
  wordContainer.innerHTML = "";
  displayedWord.forEach(letter => {
    const box = document.createElement("div");
    box.className = "letter-box";
    box.textContent = letter || "";
    wordContainer.appendChild(box);
  });
}

function renderAlphabet() {
  lettersContainer.innerHTML = "";
  alphabet.forEach(letter => {
    const btn = document.createElement("button");
    btn.className = "letter-btn";
    btn.textContent = letter;
    btn.addEventListener("click", () => handleLetterClick(btn, letter));
    lettersContainer.appendChild(btn);
  });
}

function handleLetterClick(btn, letter) {
  if (!gameActive || btn.classList.contains("selected")) return;

  btn.classList.add("selected");

  let hit = false;
  for (let i = 0; i < selectedWord.length; i++) {
    if (selectedWord[i] === letter) {
      displayedWord[i] = letter;
      hit = true;
    }
  }

  renderWord();
  if (!hit) {
    mistakes++;
    drawHangman();
  }

  checkGameStatus();
  saveGameState();
}

function checkGameStatus() {
  if (!displayedWord.includes("")) {
    messageDiv.textContent = `🎉 You won! The word was: ${selectedWord}`;
    gameActive = false;
    clearGameState();
    updateButtons();
  } else if (mistakes >= maxMistakes) {
    messageDiv.textContent = `❌ You lost! The word was: ${selectedWord}`;
    gameActive = false;
    clearGameState();
    updateButtons();
  }
}

function drawHangman() {
  ctx.lineWidth = 2;
  ctx.strokeStyle = "#333";
  ctx.beginPath();
  ctx.moveTo(10, canvas.height - 10);
  ctx.lineTo(270, canvas.height - 10);
  ctx.moveTo(40, canvas.height - 10);
  ctx.lineTo(40, 10);
  ctx.lineTo(150, 10);
  ctx.lineTo(150, 30);
  ctx.stroke();

  if (mistakes >= 1) {
    ctx.beginPath();
    ctx.arc(150, 50, 20, 0, Math.PI * 2); // head
    ctx.stroke();
  }
  if (mistakes >= 2) {
    ctx.moveTo(150, 70);
    ctx.lineTo(150, 130); // body
    ctx.stroke();
  }
  if (mistakes >= 3) {
    ctx.moveTo(150, 90);
    ctx.lineTo(120, 110); // left arm
    ctx.stroke();
  }
  if (mistakes >= 4) {
    ctx.moveTo(150, 90);
    ctx.lineTo(180, 110); // right arm
    ctx.stroke();
  }
  if (mistakes >= 5) {
    ctx.moveTo(150, 130);
    ctx.lineTo(130, 170); // left leg
    ctx.stroke();
  }
  if (mistakes >= 6) {
    ctx.moveTo(150, 130);
    ctx.lineTo(170, 170); // right leg
    ctx.stroke();
  }
}

function updateButtons() {
  if (gameActive) {
    cancelBtn.classList.remove("hidden");
    backBtn.classList.add("hidden");
  } else {
    cancelBtn.classList.add("hidden");
    backBtn.classList.remove("hidden");
  }
}

function saveGameState() {
  if (!gameActive) return;
  const state = {
    selectedWord,
    displayedWord,
    mistakes,
    usedLetters: [...document.querySelectorAll(".letter-btn.selected")].map(btn => btn.textContent)
  };
  localStorage.setItem("hangmanGame", JSON.stringify(state));
}

function loadGameState() {
  const saved = JSON.parse(localStorage.getItem("hangmanGame"));
  if (!saved) return;

  selectedWord = saved.selectedWord;
  displayedWord = saved.displayedWord;
  mistakes = saved.mistakes;
  gameActive = true;

  ctx.clearRect(0, 0, canvas.width, canvas.height);
  drawHangman();
  renderWord();
  renderAlphabet();

  // Mark used letters
  saved.usedLetters.forEach(letter => {
    const btn = [...lettersContainer.children].find(b => b.textContent === letter);
    if (btn) btn.classList.add("selected");
  });

  updateButtons();
  checkGameStatus();
}

function clearGameState() {
  localStorage.removeItem("hangmanGame");
}

// Event Listeners
startBtn.addEventListener("click", () => {
  startScreen.classList.add("hidden");
  gameContainer.classList.remove("hidden");
  initGame();
});

restartBtn.addEventListener("click", () => {
  initGame();
});

cancelBtn.addEventListener("click", () => {
  gameActive = false;
  clearGameState();
  showStartScreen();
});

backBtn.addEventListener("click", showStartScreen);

function showStartScreen() {
  gameContainer.classList.add("hidden");
  startScreen.classList.remove("hidden");
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  wordContainer.innerHTML = "";
  lettersContainer.innerHTML = "";
  messageDiv.textContent = "";
}

// Load game on page load
window.addEventListener("DOMContentLoaded", () => {
  loadGameState();
  if (gameActive) {
    startScreen.classList.add("hidden");
    gameContainer.classList.remove("hidden");
  }
});



// const words = ["KOMPUTER", "PROGRAMOWANIE", "JAVASCRIPT", "HTML", "CSS", "ALFABET", "PRZYGODA"];
// const alphabet = "AĄBCĆDEĘFGHIJKLŁMNŃOÓPRSŚTUWYZŹŻ".split("");

// const wordContainer = document.getElementById("word-container");
// const lettersContainer = document.getElementById("letters-container");
// const messageDiv = document.getElementById("message");
// const canvas = document.getElementById("hangman-canvas");
// const ctx = canvas.getContext("2d");
// const restartBtn = document.getElementById("restart-btn");
// const cancelBtn = document.getElementById("cancel-btn");


// const startScreen = document.getElementById("start-screen");
// const gameContainer = document.getElementById("game-container");
// const startBtn = document.getElementById("start-btn");
// const backBtn = document.getElementById("back-btn");


// let selectedWord = "";
// let displayedWord = [];
// let mistakes = 0;
// const maxMistakes = 6;
// let gameActive = true;

// function initGame() {
//   selectedWord = words[Math.floor(Math.random() * words.length)];
//   displayedWord = Array(selectedWord.length).fill("");
//   mistakes = 0;
//   gameActive = true;
//   messageDiv.textContent = "";
//   ctx.clearRect(0, 0, canvas.width, canvas.height);
//   drawHangman();

//   renderWord();
//   renderAlphabet();

//   saveGameState();
// }

// function renderWord() {
//   wordContainer.innerHTML = "";
//   displayedWord.forEach(letter => {
//     const letterBox = document.createElement("div");
//     letterBox.className = "letter-box";
//     letterBox.textContent = letter || "";
//     wordContainer.appendChild(letterBox);
//   });
// }

// function renderAlphabet() {
//   lettersContainer.innerHTML = "";
//   alphabet.forEach(letter => {
//     const btn = document.createElement("button");
//     btn.className = "letter-btn";
//     btn.textContent = letter;
//     btn.addEventListener("click", () => handleLetterClick(btn, letter));
//     lettersContainer.appendChild(btn);
//   });
// }

// function handleLetterClick(btn, letter) {
//   if (!gameActive || btn.classList.contains("selected")) return;

//   btn.classList.add("selected");

//   let hit = false;
//   for (let i = 0; i < selectedWord.length; i++) {
//     if (selectedWord[i] === letter) {
//       displayedWord[i] = letter;
//       hit = true;
//     }
//   }

//   renderWord();

//   if (!hit) {
//     mistakes++;
//     drawHangman();
//   }

//   checkGameStatus();
//   saveGameState();
// }


// startBtn.addEventListener("click", () => {
//   startScreen.classList.add("hidden");
//   gameContainer.classList.remove("hidden");
//   initGame();
// });

// restartBtn.addEventListener("click", () => {
//   initGame();
//   backBtn.classList.add("hidden");
//   cancelBtn.classList.remove("hidden");
// });

// cancelBtn.addEventListener("click", () => {
//   gameActive = false;
//   clearGameState();
//   showStartScreen();
// });

// backBtn.addEventListener("click", () => {
//   showStartScreen();
// });

// function showStartScreen() {
//   gameContainer.classList.add("hidden");
//   startScreen.classList.remove("hidden");
//   ctx.clearRect(0, 0, canvas.width, canvas.height);
//   wordContainer.innerHTML = "";
//   lettersContainer.innerHTML = "";
//   messageDiv.textContent = "";
// }


// function checkGameStatus() {
//   if (!displayedWord.includes("")) {
//     messageDiv.textContent = "🎉 Gratulacje! Odgadłeś słowo: " + selectedWord;
//     gameActive = false;
//     clearGameState();
//     cancelBtn.classList.add("hidden");
//     backBtn.classList.remove("hidden");
//   } else if (mistakes >= maxMistakes) {
//     messageDiv.textContent = "❌ Przegrałeś! Słowo to: " + selectedWord;
//     gameActive = false;
//     clearGameState();
//     cancelBtn.classList.add("hidden");
//     backBtn.classList.remove("hidden");
//   }
// }

// function drawHangman() {
//   ctx.lineWidth = 2;
//   ctx.strokeStyle = "#333";
//   ctx.beginPath();
//   ctx.moveTo(10, canvas.height - 10);
//   ctx.lineTo(270, canvas.height - 10);
//   ctx.moveTo(40, canvas.height - 10);
//   ctx.lineTo(40, 10);
//   ctx.lineTo(150, 10);
//   ctx.lineTo(150, 30);
//   ctx.stroke();

//   if (mistakes >= 1) {
//     ctx.beginPath();
//     ctx.arc(150, 50, 20, 0, Math.PI * 2);
//     ctx.stroke();
//   }
//   if (mistakes >= 2) {
//     ctx.moveTo(150, 70);
//     ctx.lineTo(150, 130);
//     ctx.stroke();
//   }
//   if (mistakes >= 3) {
//     ctx.moveTo(150, 90);
//     ctx.lineTo(120, 110);
//     ctx.stroke();
//   }
//   if (mistakes >= 4) {
//     ctx.moveTo(150, 90);
//     ctx.lineTo(180, 110);
//     ctx.stroke();
//   }
//   if (mistakes >= 5) {
//     ctx.moveTo(150, 130);
//     ctx.lineTo(130, 170);
//     ctx.stroke();
//   }
//   if (mistakes >= 6) {
//     ctx.moveTo(150, 130);
//     ctx.lineTo(170, 170);
//     ctx.stroke();
//   }
// }

// function saveGameState() {
//   const state = {
//     selectedWord,
//     displayedWord,
//     mistakes,
//     gameActive,
//     usedLetters: [...document.querySelectorAll(".letter-btn.selected")].map(btn => btn.textContent)
//   };
//   localStorage.setItem("hangmanGame", JSON.stringify(state));
// }

// function loadGameState() {
//   const state = JSON.parse(localStorage.getItem("hangmanGame"));
//   if (!state) return initGame();

//   selectedWord = state.selectedWord;
//   displayedWord = state.displayedWord;
//   mistakes = state.mistakes;
//   gameActive = state.gameActive;

//   ctx.clearRect(0, 0, canvas.width, canvas.height);
//   drawHangman();
//   renderWord();
//   renderAlphabet();

//   state.usedLetters.forEach(letter => {
//     const btn = [...lettersContainer.children].find(b => b.textContent === letter);
//     if (btn) btn.classList.add("selected");
//   });

//   checkGameStatus();
// }

// function clearGameState() {
//   localStorage.removeItem("hangmanGame");
// }

// restartBtn.addEventListener("click", initGame);

// cancelBtn.addEventListener("click", () => {
//   gameActive = false;
//   selectedWord = "";
//   displayedWord = [];
//   mistakes = 0;
//   messageDiv.textContent = "";
//   ctx.clearRect(0, 0, canvas.width, canvas.height);
//   wordContainer.innerHTML = "";
//   lettersContainer.innerHTML = "";
//   clearGameState();
// });

// window.addEventListener("DOMContentLoaded", loadGameState);
