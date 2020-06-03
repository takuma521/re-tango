const updateWord = () => {
  const words = document.querySelectorAll('.js-update-word');
  if (words.length === 0) {return;}
  words.forEach(word => {
    word.addEventListener('click', () => {
      if (!word.firstElementChild) {
        let form = document.createElement('form');
        form.className = 'js-update-word-form';
        let input = document.createElement('input');
        input.value = word.textContent;
        input.type = 'text';
        input.name = 'translation';
        input.className = 'js-update-word-input';
        let hiddenInput = document.createElement('input');
        hiddenInput.type = 'hidden';
        hiddenInput.name = '_method';
        hiddenInput.value = 'patch';
        form.appendChild(input);
        form.appendChild(hiddenInput);
        word.textContent = '';
        word.appendChild(form);
        document.querySelector('.js-update-word-input').focus();
      }

      document.querySelector('.js-update-word-input').addEventListener('input', () => {
        // TODO: inputを変更するたびに通信されてしまうので、修正する必要あり
        let formDatas = document.querySelector('.js-update-word-form');
        let postDatas = new FormData(formDatas);
        let XHR = new XMLHttpRequest();
        const wordId = word.dataset['json'];
        const wordUpdatePath = `${location.pathname}/${wordId}`;
        XHR.open('POST', wordUpdatePath, true);
        XHR.send(postDatas);
      }, false);

      document.querySelector('.js-update-word-input').addEventListener('blur', (input) => {
        const updateValue = input.target.value;
        word.textContent = updateValue;
        input.target.remove();
      });
    });
  });
};

document.addEventListener('DOMContentLoaded', updateWord);
document.addEventListener('DOMNodeInserted', updateWord);
