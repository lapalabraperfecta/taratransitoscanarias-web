const top_ = document.querySelector('.top');
const menuBtn = document.querySelector('.menu-btn');
menuBtn?.addEventListener('click', () => {
  const open = top_.classList.toggle('open');
  menuBtn.setAttribute('aria-expanded', open);
});

document.querySelectorAll('form.quote').forEach(form => {
  const ok = form.querySelector('.form-ok');
  const err = form.querySelector('.form-err');
  const btn = form.querySelector('button[type="submit"]');
  form.addEventListener('submit', async e => {
    e.preventDefault();
    ok.hidden = true;
    err.hidden = true;
    if ('demo' in form.dataset) {
      ok.hidden = false;
      return;
    }
    btn.disabled = true;
    try {
      const res = await fetch(form.action, {
        method: 'POST',
        body: new FormData(form),
        headers: { Accept: 'application/json' },
      });
      if (!res.ok) throw new Error(res.status);
      form.reset();
      ok.hidden = false;
    } catch {
      err.hidden = false;
    } finally {
      btn.disabled = false;
    }
  });
});

const sheet = document.querySelector('.docsheet');
if (sheet) {
  const lists = sheet.querySelectorAll('.doclist');
  const count = sheet.querySelector('output');
  const update = () => {
    const list = [...lists].find(l => !l.hidden);
    const boxes = list.querySelectorAll('input');
    const done = list.querySelectorAll('input:checked').length;
    count.textContent = `${done} de ${boxes.length} preparados`;
  };
  sheet.querySelectorAll('.tabs button').forEach(btn => {
    btn.addEventListener('click', () => {
      sheet.querySelectorAll('.tabs button').forEach(b => b.setAttribute('aria-selected', b === btn));
      lists.forEach(l => { l.hidden = l.id !== btn.getAttribute('aria-controls'); });
      update();
    });
  });
  sheet.addEventListener('change', update);
  update();
}

const heroVideo = document.querySelector('.hero-video');
const wantsVideo = matchMedia('(min-width: 761px) and (prefers-reduced-motion: no-preference)').matches;
if (heroVideo && wantsVideo && !navigator.connection?.saveData) {
  heroVideo.src = heroVideo.dataset.src;
  // Funde a la imagen de espera (el primer fotograma) antes de volver a empezar
  heroVideo.addEventListener('timeupdate', () => {
    heroVideo.classList.toggle('fade', heroVideo.duration - heroVideo.currentTime < 0.7);
  });
  heroVideo.addEventListener('ended', () => {
    heroVideo.currentTime = 0;
    heroVideo.play();
  });
  heroVideo.play().catch(() => {});
}
