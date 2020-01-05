var emoji = new EmojiConvertor();

emoji.img_sets.apple.path = 'https://raw.githubusercontent.com/iamcal/emoji-data/master/img-apple-64/';
emoji.img_sets.google.path = 'https://raw.githubusercontent.com/iamcal/emoji-data/master/img-google-64/';
emoji.img_sets.emojione.path = 'https://raw.githubusercontent.com/iamcal/emoji-data/master/img-emojione-64/';
emoji.img_sets.twitter.path = 'https://raw.githubusercontent.com/iamcal/emoji-data/master/img-twitter-64/';
emoji.use_sheet = false;

var messagesElement = document.getElementById('messages');
var bottomElement = document.getElementById('bottom');
var inputFormElement = document.getElementById('inputForm');
var inputFieldElement = document.getElementById('inputField');
var settingsButtonElement = document.getElementById('settingsButton');

function openUrl(element) {
    speak.OpenUrl(element.href);
    return false;
}

var ChatboxInstance = (function () {
    function CheckForColor(object) {
        return object.hasOwnProperty('r') && object.hasOwnProperty('g') && object.hasOwnProperty('b') && object.hasOwnProperty('a');
    }
    function CheckForMultiplier(object) {
        return object.hasOwnProperty('value');
    }
    function CheckForEmoticon(object) {
        return object.hasOwnProperty('code') && object.hasOwnProperty('url');
    }
    function CheckForImage(object) {
        return object.hasOwnProperty('url');
    }
    function CheckForAvatar(object) {
        return object.hasOwnProperty('steamId') && object.hasOwnProperty('sheetX') && object.hasOwnProperty('sheetY');
    }
    function CheckForMention(object) {
        return object.hasOwnProperty('mentionId') && object.hasOwnProperty('mentionText');
    }

    function Chatbox(messagesElement, bottomElement, inputFormElement, inputFieldElement, settingsButtonElement) {
        Object.defineProperties(this,
        {
            messagesElement: {
                value: messagesElement
            },
            bottomElement: {
                value: bottomElement
            },
            inputFormElement: {
                value: inputFormElement
            },
            inputFieldElement: {
                value: inputFieldElement
            },
            settingsButtonElement: {
                value: settingsButtonElement
            },

            _currentScrollTop: {
                value: messagesElement.scrollTop,
                writable: true
            },

            _history: {
                value: [],
                writable: true
            },
            _historyIndex: {
                value: -1,
                writable: true
            },

            // Avatars
            _avatarEnabled: {
                value: false,
                writable: true
            },
            avatarEnabled: {
                set: function (value) {
                    this._avatarEnabled = value;
                    this._updateAvatarEnabled();
                },
                get: function () {
                    return this._avatarEnabled;
                }
            },
            avatarSheet: {
                value: '',
                writable: true
            },

            // Font
            _fontName: {
                value: '',
                writable: true
            },
            fontName: {
                set: function (value) {
                    this._fontName = value;
                    document.body.style.fontFamily = value + ', Arial, sans-serif';
                },
                get: function () {
                    return this._fontName;
                }
            },
            _fontSize: {
                value: 0,
                writable: true
            },
            fontSize: {
                set: function (value) {
                    this._fontSize = value;
                    document.body.style.fontSize = value + 'pt';
                },
                get: function () {
                    return this._fontSize;
                }
            },
            _fontWeight: {
                value: 0,
                writable: true
            },
            fontWeight: {
                set: function (value) {
                    this._fontWeight = value;
                    document.body.style.fontWeight = value;
                    inputFieldElement.style.fontWeight = value;
                },
                get: function () {
                    return this._fontWeight;
                }
            },

            // Font Border
            _fontBorderType: {
                value: 0,
                writable: true
            },
            fontBorderType: {
                set: function (value) {
                    this._fontBorderType = value;
                    this._updateFontBorder();
                },
                get: function () {
                    return this._fontBorderType;
                }
            },
            _fontBorderBlur: {
                value: 0,
                writable: true
            },
            fontBorderBlur: {
                set: function (value) {
                    this._fontBorderBlur = value;
                    this._updateFontBorder();
                },
                get: function () {
                    return this._fontBorderBlur;
                }
            },
            _fontBorderOpacity: {
                value: 0,
                writable: true
            },
            fontBorderOpacity: {
                set: function (value) {
                    this._fontBorderOpacity = value;
                    this._updateFontBorder();
                },
                get: function () {
                    return this._fontBorderOpacity;
                }
            },

            // Emoji
            emojiSet: {
                set: function (value) {
                    emoji.img_set = value;
                },
                get: function () {
                    return emoji.img_set;
                }
            },

            _isOpen: {
                value: false,
                writable: true
            },
            _isTeamChat: {
                value: false,
                writable: true
            }
        });

        this.inputFormElement.addEventListener('submit', (function (e) {
            e.preventDefault();

            var canSay = /\S/.test(this.inputFieldElement.value);

            if(canSay) {
                if (this._isTeamChat) {
                    speak.SayTeam(this.inputFieldElement.value);
                } else {
                    speak.Say(this.inputFieldElement.value);
                }

                // Avoid duplicates
                if(this._history[0] !== this.inputFieldElement.value) {
                    this._history.unshift(this.inputFieldElement.value);
                }
            }

            speak.Close();

            this._historyIndex = -1;
            this.inputFieldElement.value = '';

            this.scroll();
        }).bind(this));

        this.inputFieldElement.addEventListener('keydown', (function (e) {
            if (e.keyCode === 9) {
                this.inputFieldElement.value = speak.PressTab(this.inputFieldElement.value);
                e.preventDefault();
            } else {
                speak.ClearEmojo();
            }

            if(e.keyCode === 38) {
                if(this._history[this._historyIndex + 1] !== undefined) {
                   this._historyIndex++;
                } 

                this.inputFieldElement.value = this._history[this._historyIndex] || this.inputFieldElement.value;
            } else if(e.keyCode === 40) {
                if(this._history[this._historyIndex - 1] !== undefined) {
                   this._historyIndex--;
                   this.inputFieldElement.value = this._history[this._historyIndex];
                } else {
                    this._historyIndex = -1;
                    this.inputFieldElement.value = '';
                }
            } else {
                this._historyIndex = -1;
            }
        }).bind(this));

        this.inputFieldElement.addEventListener('input', (function(e) {
            speak.TextChanged(this.inputFieldElement.value);
        }).bind(this));

        this.inputFieldElement.addEventListener('blur', (function (e) {
            this.inputFieldElement.value = '';
        }).bind(this));

        this.settingsButtonElement.addEventListener('click', function (e) {
            speak.OpenSettings();
        });

        // Callback to Lua, chatbox has been initialized
        speak.ChatInitialized();
    }

    Chatbox.prototype._updateAvatarEnabled = function () {
        var avatars = document.getElementsByClassName('avatar');

        for (var i = 0; i < avatars.length; i++) {
            avatars[i].style.display = this.avatarEnabled ? 'inline-block' : 'none';
        }
    };

    Chatbox.prototype._updateFontBorder = function () {
        if (this.fontBorderType) {
            document.body.style.textShadow = '1px 1px ' + this.fontBorderBlur + 'px rgba(0, 0, 0, ' + this.fontBorderOpacity + ')';

            this.settingsButtonElement.style.webkitFilter = 'drop-shadow(1px 1px ' + this.fontBorderBlur + 'px rgba(0, 0, 0, ' + this.fontBorderOpacity + '))';
        } else {
            document.body.style.textShadow =
                '1px 0px ' + this.fontBorderBlur + 'px rgba(0, 0, 0, ' + this.fontBorderOpacity + '), \
                        0 1px ' + this.fontBorderBlur + 'px rgba(0, 0, 0, ' + this.fontBorderOpacity + '), \
                        -1px 0px ' + this.fontBorderBlur + 'px rgba(0, 0, 0, ' + this.fontBorderOpacity + '), \
                        0 -1px ' + this.fontBorderBlur + 'px rgba(0, 0, 0, ' + this.fontBorderOpacity + '), \
                        1px 1px ' + this.fontBorderBlur + 'px rgba(0, 0, 0, ' + this.fontBorderOpacity + '), \
                        -1px -1px ' + this.fontBorderBlur + 'px rgba(0, 0, 0, ' + this.fontBorderOpacity + '), \
                        -1px 1px ' + this.fontBorderBlur + 'px rgba(0, 0, 0, ' + this.fontBorderOpacity + '), \
                        1px -1px ' + this.fontBorderBlur + 'px rgba(0, 0, 0, ' + this.fontBorderOpacity + ')';

            this.settingsButtonElement.style.webkitFilter = 'drop-shadow(0px 0px ' + this.fontBorderBlur + 'px rgba(0, 0, 0, ' + this.fontBorderOpacity + '))';
        }
    };

    Chatbox.prototype.open = function (isTeamChat, say, sayTeam) {
        if (this._isOpen) {
            return;
        }
        this._isOpen = true;
        this._isTeamChat = isTeamChat;

        this.inputFieldElement.placeholder = isTeamChat ? sayTeam : say;

        this.messagesElement.classList.toggle('open');
        this.bottomElement.classList.toggle('open');
    };

    Chatbox.prototype.close = function () {
        if (!this._isOpen) {
            return;
        }
        this._isOpen = false;

        this.messagesElement.classList.toggle('open');
        this.bottomElement.classList.toggle('open');

        // Reset selections
        window.getSelection().empty();

        this.scroll();
    };

    Chatbox.prototype.appendLine = function (object) {
        if (this._isOpen && this.messagesElement.scrollTop === (this.messagesElement.scrollHeight - this.messagesElement.offsetHeight)) {
            this._currentScrollTop = this.messagesElement.scrollTop;
        }

        // List element for container
        var listElement = document.createElement('li');

        listElement.className = 'newMessage';

        // Default color
        var lastColor = { r: 151, b: 211, g: 255, a: 255 };

        // Default multiplier
        var lastMultiplier = { value: 1 };

        for (var index in object) {
            var currentObject = object[index];

            if (typeof (currentObject) == 'object') {
                if (CheckForColor(currentObject)) {  // Color parsing
                    lastColor = currentObject;
                } else if (CheckForMultiplier(currentObject)) { // Font size increase for Clockwork support
                    lastMultiplier = currentObject;
                } else if (CheckForEmoticon(currentObject)) { // Emoticon parsing
                    var imageElement = document.createElement('img');

                    imageElement.classList.add('emoji');
                    imageElement.src = currentObject.url;
                    imageElement.setAttribute('alt', currentObject.code);

                    listElement.appendChild(imageElement);
                } else if (CheckForImage(currentObject)) { // Image parsing (emoticon without alt tag)
                    var imageElement = document.createElement('img');

                    imageElement.classList.add('emoji');
                    imageElement.src = currentObject.url;

                    listElement.appendChild(imageElement);
                } else if (CheckForAvatar(currentObject)) { // Avatar parsing
                    var avatarElement = document.createElement('span');

                    avatarElement.classList.add('avatar');

                    if (!this.avatarEnabled) {
                        avatarElement.style.display = 'none';
                    }

                    avatarElement.setAttribute('sheetX', currentObject.sheetX);
                    avatarElement.setAttribute('sheetY', currentObject.sheetY);
                    avatarElement.style.background = 'url(data:image/png;base64,' + this.avatarSheet + ') ' + (-currentObject.sheetX * 2) + 'em ' + (-currentObject.sheetY * 2) + 'em';

                    var id = currentObject.steamId + '';
                    avatarElement.onclick = function () {
                        speak.OpenUrl("https://steamcommunity.com/profiles/" +  id)
                    };

                    listElement.appendChild(avatarElement);
                } else if (CheckForMention(currentObject)) { // Mention parsing
                    var anchorElement = document.createElement('a');

                    anchorElement.textContent = currentObject.mentionText;

                    var id = currentObject.mentionId;
                    anchorElement.onclick = function() {
                        speak.OpenUrl("https://steamcommunity.com/profiles/" +  id)
                    };

                    listElement.appendChild(anchorElement);
                }
            } else {
                var textElement = document.createElement('span');

                // Set color
                textElement.style.color = 'rgba(' + lastColor.r + ',' + lastColor.g + ',' + lastColor.b + ',' + lastColor.a + ')';

                // Set font multiplier
                textElement.style.fontSize = lastMultiplier.value * 100 + '%';

                // Parse emoji
                textElement.textContent = currentObject;
                if (speak.GetPref("emoji_enabled")) {
                    textElement.textContent = emoji.replace_emoticons_with_colons(textElement.textContent);
                    textElement.innerHTML = emoji.replace_colons(textElement.innerHTML);
                }

                // Autolink
                textElement.innerHTML = textElement.innerHTML.autoLink({ onclick: 'return openUrl(this);' });

                listElement.appendChild(textElement);
            }
        }

        // Limit to 500 messages
        if(this.messagesElement.childNodes.length >= 500) {
            this.messagesElement.removeChild(this.messagesElement.firstChild);
        }

        // Add the list element to the list
        this.messagesElement.appendChild(listElement);

        setTimeout((function () {
            // Fade in
            listElement.className = '';
        }).bind(this), 10);
            
        // Expire message in 10 seconds then animate out if applicable
        setTimeout((function () {
            // Make message expired
            listElement.classList.toggle('expired');
        }).bind(this), 9000);

        this.scroll();
    };

    Chatbox.prototype.scroll = function () {
        // User has control over scrolling, don't do anything
        if (this._isOpen && this.messagesElement.scrollTop !== this._currentScrollTop) {
            return;
        }

        this.messagesElement.scrollTop = this.messagesElement.scrollHeight;
        this._currentScrollTop = this.messagesElement.scrollTop;
    };

    var arrayArguments = Array.apply(null, arguments),
        concatArguments = [null].concat(arrayArguments),
        boundConstructor = Function.prototype.bind.apply(Chatbox, concatArguments);

    return new boundConstructor;
})(messagesElement, bottomElement, inputFormElement, inputFieldElement, settingsButtonElement);