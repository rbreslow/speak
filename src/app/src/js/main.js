import EmojiConvertor from 'emoji-js';
import 'autolink-js';
import autocomplete from 'autocompleter';

import '../sass/main.scss';

const emoji = new EmojiConvertor();

emoji.img_sets.apple.path = 'https://cdn.jsdelivr.net/npm/emoji-datasource-apple@4.1.0/img/apple/64/';
emoji.img_sets.google.path = 'https://cdn.jsdelivr.net/npm/emoji-datasource-google@4.1.0/img/google/64/';
emoji.img_sets.twitter.path = 'https://cdn.jsdelivr.net/npm/emoji-datasource-twitter@4.1.0/img/twitter/64/';
emoji.img_sets.facebook.path = 'https://cdn.jsdelivr.net/npm/emoji-datasource-facebook@4.1.0/img/facebook/64/';
emoji.img_sets.messenger.path = 'https://cdn.jsdelivr.net/npm/emoji-datasource-messenger@4.1.0/img/messenger/64/';

const messages = document.getElementById('messages');
const footer = document.getElementById('footer');
const inputForm = document.getElementById('input-form');
const inputField = document.getElementById('input-field');
const settingsButton = document.getElementById('settings-btn');

// cache the lookup once, in module scope.
const has = Object.prototype.hasOwnProperty;
const arrayForEach = Array.prototype.forEach;

// https://stackoverflow.com/questions/512528/set-keyboard-caret-position-in-html-textbox
function setCaretPosition(elemId, caretPos) {
  const elem = document.getElementById(elemId);

  if (elem != null) {
    if (elem.createTextRange) {
      const range = elem.createTextRange();
      range.move('character', caretPos);
      range.select();
    } else if (elem.selectionStart) {
      elem.focus();
      elem.setSelectionRange(caretPos, caretPos);
    } else elem.focus();
  }
}

function isColor(object) {
  return has.call(object, 'r') && has.call(object, 'g') && has.call(object, 'b') && has.call(object, 'a');
}

function isMultiplier(object) {
  return has.call(object, 'value');
}

function isEmoticon(object) {
  return has.call(object, 'code') && has.call(object, 'url');
}

function isImage(object) {
  return has.call(object, 'url');
}

function isAvatar(object) {
  return has.call(object, 'steamId') && has.call(object, 'sheetX') && has.call(object, 'sheetY');
}

function isMention(object) {
  return has.call(object, 'mentionId') && has.call(object, 'mentionText');
}

// https://jsfiddle.net/intrinsica/9ryqet30
function easeInOutSmoother(t) {
  const ts = t * t;
  const tc = ts * t;
  return 6 * tc * ts - 15 * ts * ts + 10 * tc;
}

function lerp(delta, from, to) {
  if (delta > 1) { return to; }
  if (delta < 0) { return from; }

  return from + (to - from) * delta;
}

function clamp(_in, low, high) {
  return Math.min(Math.max(_in, low), high);
}

class ChatboxState {
  constructor() {
    this.currentScrollTop = messages.scrollTop;
    this.history = [];
    this.historyIndex = -1;

    this.avatarEnabled = true;
    this.avatarSheet = '';

    this.emojiEnabled = true;

    this.fontBorderType = true;
    this.fontBorderBlur = 0;
    this.fontBorderOpacity = 0;

    this.isOpen = false;
    this.isTeamChat = false;

    inputForm.addEventListener('submit', ((e) => {
      e.preventDefault();

      // if the user has scrolled up, teleport to the bottom
      if (messages.scrollTop !== this.currentScrollTop) {
        this.scroll(true);
      }

      const canSay = /\S/.test(inputField.value);

      if (canSay) {
        speak.Close();

        if (this.isTeamChat) {
          speak.SayTeam(inputField.value);
        } else {
          speak.Say(inputField.value);
        }

        // avoid duplicates
        if (this.history[0] !== inputField.value) {
          this.history.unshift(inputField.value);
        }
      } else {
        speak.Close();
      }

      this.historyIndex = -1;
      inputField.value = '';
    }));

    inputField.addEventListener('keydown', ((e) => {
      if (e.keyCode === 9) {
        speak.PressTab(inputField.value, (str) => {
          inputField.value = str;
        });
        e.preventDefault();
      } else {
        speak.ClearEmojo();
      }

      if (e.keyCode === 38) {
        if (this.history[this.historyIndex + 1] !== undefined) {
          this.historyIndex += 1;
        }

        inputField.value = this.history[this.historyIndex]
          || inputField.value;
        setCaretPosition(inputField, inputField.value.length);
        e.preventDefault();
      } else if (e.keyCode === 40) {
        if (this.history[this.historyIndex - 1] !== undefined) {
          this.historyIndex -= 1;
          inputField.value = this.history[this.historyIndex];
          setCaretPosition(inputField, inputField.value.length);
          e.preventDefault();
        } else {
          this.historyIndex = -1;
          inputField.value = '';
          setCaretPosition(inputField, inputField.value.length);
          e.preventDefault();
        }
      } else {
        this.historyIndex = -1;
      }

      if(e.keyCode === 13) {
          // I know.
        const autocompletes = document.getElementsByClassName('autocomplete ');

        console.log(autocompletes.length + "");

        for(var i = 0; i < autocompletes.length; i++) {
          const autocomplete = autocompletes[i];
          console.log("patrol");

          // Do not submit if we are selecting an autocomplete suggestion
          if(autocomplete.parentNode) {
            console.log("holla");
            e.preventDefault();
          }
        }
      }

      if (inputField.value.length === 128) {
        speak.MaxLengthHit();
      }
    }));

    inputField.addEventListener('input', (e) => {
      // hack to make autocompletion work
      // https://github.com/kraaden/autocomplete/blob/e1732fd9309d7c5ae2382bc2a0cc70271954052a/autocomplete.js#L22
      inputField.dispatchEvent(new CustomEvent('keyup', e));
      speak.TextChanged(inputField.value)
    });
    settingsButton.addEventListener('click', () => speak.OpenSettings());

    // this is a hack to reduce the choppiness of the scroll() animation after
    // chatbox has been resized
    window.addEventListener('resize', () => {
      this.scroll(true);
    });

    speak.GetAutocompletionData(data => {
      let emojis = [];

      for(let i = 0; i < data.length; i++) {
        emojis.push({ label: data[i], value : data[i] });
      } 

      autocomplete({
        input: inputField,
        //minLength: 3,
        onSelect: function(item) {
          let str = ""
          let lastIndex = inputField.value.lastIndexOf(" ");
          str = inputField.value.substring(0, lastIndex);

          inputField.value = `${str}${(str.length > 0 ? " " : "")}${item.label}`;
        },
        render: function(item, value) {
          const itemElement = document.createElement("div");

          let emojiElement = item.label
          emojiElement = emoji.replace_emoticons_with_colons(emojiElement);
          emojiElement = emoji.replace_colons(emojiElement);

          arrayForEach.call(value.match(/([^ ]+)/g), word => {
            value = word
          });

          value = value.match(/:([^:]+):?/)[1];
          const regex = new RegExp(value, 'gi');
          const inner = `${emojiElement}&nbsp;${item.label.replace(regex, match => { return `<mark>${match}</mark>` })}`;
          itemElement.innerHTML = inner;

          return itemElement;
        },
        fetch: function(text, update) {
          let lastWord = ""
          arrayForEach.call(text.match(/([^ ]+)/g), word => {
            lastWord = word
          });

          if(lastWord.length < 4) {
            return;
          }

          if(lastWord.substring(0, 1) !== ":") {
            return;
          }

          const match = lastWord.toLowerCase();
          update(emojis.filter((n) => { return n.label.toLowerCase().indexOf(match) !== -1; }));
        },
        customize: function(input, inputRect, container, maxHeight) {
          container.style.top = "";
          container.style.bottom = (window.innerHeight - inputRect.bottom + input.offsetHeight) + "px";
          container.style.maxHeight = "6em";
        }
      });
    });

    // callback to Lua, chatbox has been initialized
    if (typeof speak !== 'undefined' && has.call(speak, 'ChatInitialized')) {
      speak.ChatInitialized();
    }
  }

  setAvatarEnabled(avatarEnabled) {
    this.avatarEnabled = avatarEnabled;
  }

  static setFontName(fontName) {
    document.body.style.fontFamily = `${fontName}, Arial, sans-serif`;
  }

  static setFontSize(fontSize) {
    document.body.style.fontSize = `${fontSize}pt`;
  }

  static setFontWeight(fontWeight) {
    document.body.style.fontWeight = fontWeight;
    inputField.style.fontWeight = fontWeight;
  }

  setFontBorderType(fontBorderType) {
    this.fontBorderType = fontBorderType;
    this.updateFontBorder();
  }

  setFontBorderBlur(fontBorderBlur) {
    this.fontBorderBlur = fontBorderBlur;
    this.updateFontBorder();
  }

  setFontBorderOpacity(fontBorderOpacity) {
    this.fontBorderOpacity = fontBorderOpacity;
    this.updateFontBorder();
  }

  updateFontBorder() {
    const buttons = document.getElementsByClassName('footer__btn');

    if (this.fontBorderType) {
      document.body.style.textShadow = `1px 1px ${this.fontBorderBlur}px rgba(0, 0, 0, ${this.fontBorderOpacity})`;

      arrayForEach.call(buttons, (button) => {
        button.style.webkitFilter = `drop-shadow(1px 1px ${this.fontBorderBlur}px rgba(0, 0, 0, ${this.fontBorderOpacity}))`; // eslint-disable-line no-param-reassign
      });
    } else {
      document.body.style.textShadow = `1px 0px ${this.fontBorderBlur}px rgba(0, 0, 0, ${this.fontBorderOpacity}), \
                        0 1px ${this.fontBorderBlur}px rgba(0, 0, 0, ${this.fontBorderOpacity}), \
                        -1px 0px ${this.fontBorderBlur}px rgba(0, 0, 0, ${this.fontBorderOpacity}), \
                        0 -1px ${this.fontBorderBlur}px rgba(0, 0, 0, ${this.fontBorderOpacity}), \
                        1px 1px ${this.fontBorderBlur}px rgba(0, 0, 0, ${this.fontBorderOpacity}), \
                        -1px -1px ${this.fontBorderBlur}px rgba(0, 0, 0, ${this.fontBorderOpacity}), \
                        -1px 1px ${this.fontBorderBlur}px rgba(0, 0, 0, ${this.fontBorderOpacity}), \
                        1px -1px ${this.fontBorderBlur}px rgba(0, 0, 0, ${this.fontBorderOpacity})`;

      arrayForEach.call(buttons, (button) => {
        button.style.webkitFilter = `drop-shadow(0px 0px ${this.fontBorderBlur}px rgba(0, 0, 0, ${this.fontBorderOpacity}))`; // eslint-disable-line no-param-reassign
      });
    }
  }

  open(isTeamChat, say, sayTeam) {
    if (this.isOpen) {
      return;
    }

    this.isOpen = true;
    this.isTeamChat = isTeamChat;

    inputField.placeholder = isTeamChat ? sayTeam : say;

    messages.classList.toggle('messages--open');
    footer.classList.toggle('footer--open');

    // this ensures there will only ever be one timer, for example, if
    // someone is spamming open and close
    if (this.openingTimeout) {
      clearTimeout(this.openingTimeout);
    }
    // toggle opening CSS animation
    messages.classList.toggle('messages--opening');
    // we only want the animation to run once
    this.openingTimeout = setTimeout(() => messages.classList.toggle('messages--opening'), 10);
  }

  close() {
    if (!this.isOpen) {
      return;
    }

    this.isOpen = false;

    messages.classList.toggle('messages--open');
    footer.classList.toggle('footer--open');

    if (this.closingTimeout) {
      clearTimeout(this.closingTimeout);
    }
    // toggle the CSS class for faster list element transitions so the
    // messages will disappear at the same rate as the background
    messages.classList.toggle('messages--closing');
    // the 250ms delay is part of a hack that is explained in main.scss
    this.closingTimeout = setTimeout(() => messages.classList.toggle('messages--closing'), 250);

    // reset selections
    window.getSelection().empty();

    // clear input field
    inputField.value = '';

    // scroll to the bottom
    this.scroll();
  }

  addText(obj) {
    // if we resize the chatbox so it grows vertically and then append a
    // message, some how it overrides messages.scrollTop as soon as
    // messages.appendChild is invoked, in such a way that the end value of the
    // scroll animation is already in place. capture the correct value here and
    // reset after appending the message. this is a hack.
    const { scrollTop } = messages;

    const message = document.createElement('li');
    message.classList.toggle('messages__message');
    message.classList.toggle('messages__message--new');

    // default color
    let lastColor = {
      r: 151,
      g: 255,
      b: 211,
      a: 255,
    };

    // default multiplier
    let lastMultiplier = { value: 1 };

    obj.forEach((currentObject) => {
      if (typeof (currentObject) === 'object') {
        if (isColor(currentObject)) {
          lastColor = currentObject;
        } else if (isMultiplier(currentObject)) {
          lastMultiplier = currentObject;
        } else if (isEmoticon(currentObject)) {
          const emoticon = document.createElement('img');

          emoticon.classList.toggle('emoji');
          emoticon.src = currentObject.url;
          emoticon.setAttribute('alt', currentObject.code);

          message.appendChild(emoticon);
        } else if (isImage(currentObject)) {
          const image = document.createElement('img');

          image.classList.toggle('emoji');
          image.src = currentObject.url;

          message.appendChild(image);
        } else if (isAvatar(currentObject)) {
          const avatar = document.createElement('span');

          avatar.classList.toggle('avatar');

          if (!this.avatarEnabled) {
            avatar.style.display = 'none';
          }

          avatar.style.background = `url(data:image/png;base64,${this.avatarSheet}) ${-currentObject.sheetX * 2}em ${-currentObject.sheetY * 2}em`;
          avatar.style.backgroundSize = '24em 12em';

          avatar.onclick = () => speak.OpenUrl(`https://steamcommunity.com/profiles/${currentObject.steamId}`);

          message.appendChild(avatar);
        } else if (isMention(currentObject)) {
          const anchor = document.createElement('a');

          anchor.textContent = currentObject.mentionText;

          anchor.onclick = () => speak.OpenUrl(`https://steamcommunity.com/profiles/${currentObject.mentionId}`);

          message.appendChild(anchor);
        }
      } else {
        const text = document.createElement('span');

        text.textContent = currentObject;

        // add style
        text.style.color = `rgba(${lastColor.r}, ${lastColor.g}, ${lastColor.b}, ${lastColor.a})`;
        text.style.fontSize = `${lastMultiplier.value * 100}%`;

        // parse emoji
        if (this.emojiEnabled) {
          // for example, replace :D with :joy:
          text.textContent = emoji.replace_emoticons_with_colons(text.textContent);
          // for example, replace :joy: with an emoji object
          text.innerHTML = emoji.replace_colons(text.innerHTML);
          // replace unicode emoji literal with an emoji object
          text.innerHTML = emoji.replace_unified(text.innerHTML);
        }

        // parse hyperlinks
        text.innerHTML = text.innerHTML.autoLink();
        arrayForEach.call(text.children, (child) => {
          if (child.href) {
            const href = child.href.valueOf();
            // https://github.com/airbnb/javascript/issues/641#issuecomment-250997824
            /* eslint-disable no-param-reassign */
            child.href = '#';
            child.onclick = () => speak.OpenUrl(href);
            /* eslint-enable no-param-reassign */
          }
        });

        message.appendChild(text);
      }
    });

    // FIXME: limit to 500 messages
    if (messages.childNodes.length >= 500) {
      messages.removeChild(messages.firstChild);
    }

    // append message to messages array
    messages.appendChild(message);

    // restore correct messages.scrollTop value (see above)
    messages.scrollTop = scrollTop;

    // remove --new modifier class which represrents a fade in animation
    setTimeout(() => message.classList.toggle('messages__message--new'), 10);

    // after 16 seconds, fade the message out
    setTimeout(() => message.classList.toggle('messages__message--expired'), 16000);

    this.scroll();
  }

  scroll(skipAnim) {
    // if the element has been totally scrolled
    if (messages.scrollHeight - messages.scrollTop === messages.clientHeight) {
      return;
    }

    if (skipAnim) {
      messages.scrollTop = (messages.scrollHeight - messages.clientHeight);
      this.currentScrollTop = messages.scrollTop;
      return;
    }

    // the user is scrolling, don't do anything
    if (this.isOpen && messages.scrollTop !== this.currentScrollTop) {
      return;
    }

    // scale the lifetime of the animation to the size of the chatbox so the
    // motion always is fixed. the value here is arbitrary, based on what
    // "looks good"
    const lifeTime = messages.clientHeight * 1;

    const startVal = messages.scrollTop;
    const endVal = (messages.scrollHeight - messages.clientHeight);

    let startTime = null;
    let value = startVal;

    const think = (curTime) => {
      if (!startTime) {
        startTime = curTime;
      }

      let fraction = (curTime - startTime) / lifeTime;
      fraction = clamp(fraction, 0, 1);

      fraction = easeInOutSmoother(fraction);

      value = lerp(fraction, startVal, endVal);

      if (value < endVal) {
        messages.scrollTop = value;
        this.currentScrollTop = messages.scrollTop;
        window.requestAnimationFrame(think);
      }
    };

    window.requestAnimationFrame(think);
  }

  static focus() {
    inputField.focus();
  }

  static setEmojiSet(emojiSet) {
    emoji.img_set = emojiSet;
  }
}

export default new ChatboxState();
export { ChatboxState };
