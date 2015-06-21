function onclickToggleDone() {
    var elems = document.querySelectorAll('[id^="done"]');
    [].map.call(elems, function(obj) {
        obj.onclick = function() {
            window.location.href = '/done?id=' + obj.id.replace('done', '');
        };
    });
}
