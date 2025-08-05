window.addEventListener('load', function() {
    // Avvia il suono
    const loadingSound = document.getElementById('loading-sound');
    loadingSound.volume = 0.5;
    loadingSound.muted = false;

    // Avvia l'audio
    loadingSound.play();

    // Forza l'autoplay con unmute al click
    document.addEventListener('click', function() {
        loadingSound.play();
        loadingSound.muted = false;
    }, { once: true });

    // Aspetta 3.5 secondi prima di iniziare la dissolvenza
    setTimeout(function() {
        // Aggiunge l'effetto di dissolvenza
        document.querySelector('.loading-screen').style.opacity = '0';

        // Sfuma il suono gradualmente
        const fadeAudio = setInterval(function() {
            if (loadingSound.volume > 0.1) {
                loadingSound.volume -= 0.1;
            } else {
                loadingSound.pause();
                loadingSound.currentTime = 0;
                clearInterval(fadeAudio);
            }
        }, 50);

        // Rimuove la loading screen dopo 0.5 secondi
        setTimeout(function() {
            document.querySelector('.loading-screen').style.display = 'none';
        }, 500);
    }, 500); // Tempo per la durata della loading screen (3.5s)
});