let sounds = ["0.wav", "1.wav", "2.wav", "3.wav", "4.wav", "5.wav", "6.wav", "7.wav", "8.wav", "9.wav", "10.wav", "11.mp3", "12.wav"];
let colors = ["white", "#91caff", "#fbbfff", "#fceeb6"];
let pics = ["1", "2", "3", "4", "5", "6", "7", "8"];
let maxPicsToShow = 20;
var modal = document.getElementById("aboutModal");
var btn = document.getElementById("aboutbutton");
var span = document.getElementsByClassName("close")[0];

btn.onclick = function () {
	modal.style.display = "block";
};

span.onclick = function () {
	modal.style.display = "none";
};

window.onclick = function (event) {
	if (event.target == modal) {
		modal.style.display = "none";
	}
};
document.addEventListener("keypress", () => {
	setTimeout(() => {
		playSound();
	}, 100);
	changeBackground();
	addRandomDiv();
});

function playSound() {
	let sd = new Audio();
	sd.src = "./audio/" + sounds[Math.floor(Math.random() * sounds.length)];
	sd.play();
}

function changeBackground() {
	document.querySelector("body").style.backgroundColor = colors[Math.floor(Math.random() * colors.length)];
}

function addRandomDiv() {
	let contentDiv = document.createElement("div");
	contentDiv.className = "random-content";
	contentDiv.style.backgroundImage = `url("./pics/${pics[Math.floor(Math.random() * pics.length)]}.png")`;
	contentDiv.style.marginLeft = `${Math.floor(Math.random() * 90)}%`;
	contentDiv.style.marginTop = `${Math.floor(Math.random() * 50)}%`;
	document.body.appendChild(contentDiv);
	removeLastDiv();
}

function removeLastDiv() {
	let contentDiv = document.querySelectorAll(".random-content");
	if (contentDiv.length > maxPicsToShow) {
		contentDiv.forEach((element) => {
			document.body.removeChild(element);
		});
	}
}
