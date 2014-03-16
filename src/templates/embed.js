(function(cloverite) {
    var _scripTagId = '{{SCRIPT_ID}}',
    styleTag        = document.createElement('link');

    styleTag.rel   = 'stylesheet';
    styleTag.type  = 'text/css';
    styleTag.href  = 'http://cloverite.com:9000/static/embed/style.css';
    styleTag.media = 'all';
    document.getElementsByTagName('head')[0].appendChild(styleTag);

    styleTag       = document.createElement('link');
    styleTag.rel   = 'stylesheet';
    styleTag.type  = 'text/css';
    styleTag.href  = 'http://cloverite.com:9000/static/css/cleanslate.css';
    styleTag.media = 'all';
    document.getElementsByTagName('head')[0].appendChild(styleTag);

    var div       = document.createElement('div');
    div.id        = '{{DIV_ID}}';
    div.className = 'cleanslate cloverite-container';
    div.innerHTML = '{{{RENDERED}}}';

    scriptTag = document.getElementById(_scripTagId);
    scriptTag.parentNode.insertBefore(div, scriptTag);
})(this);
