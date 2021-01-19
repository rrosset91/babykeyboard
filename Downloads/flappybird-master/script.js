console.log('Flappy Bird - Roger Rosset. Feito com o Guia de Dev Soutinho');

const sprites = new Image();
sprites.src = './sprites.png';

const canvas = document.querySelector('canvas');
const context = canvas.getContext('2d');

const bird = {
    spriteX: 0,
    spriteY: 0,
    width: 34,
    height: 24,
    canvasStartX: 10, 
    canvasStartY: 50,
    draw () {
        context.drawImage(
            sprites,
            bird.spriteX , bird.spriteY,
            bird.width , bird.height,
            bird.canvasStartX , bird.canvasStartY,
            bird.width , bird.height,
        );
    }
}

function gameLoop(){
    bird.draw(); 
    requestAnimationFrame(gameLoop);
}
gameLoop();