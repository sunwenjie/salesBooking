/*
 Copyright (c) 2008, Bubbling Library Team. All rights reserved.
 Portions Copyright (c) 2008, Yahoo!, Inc. All rights reserved.
 Code licensed under the BSD License:
 http://www.bubbling-library.com/eng/licence
 version: 2.0
 */
(function(){
    var C = YAHOO.Bubbling, D = YAHOO.lang, A = YAHOO.util.Event, B = YAHOO.util.Dom, E = YAHOO.util.Dom.get;
    YAHOO.widget.Loading = function(){
        var K = {}, F = "yui-cms-loading", L = "yui-cms-float", I = false, P = false, M = true, J = null, Q = {}, H = {
            zIndex: 10000,
            left: 0,
            top: 0,
            margin: 0,
            padding: 0,
            opacity: 0,
            overflow: "hidden",
            visibility: "visible",
            position: "absolute",
            display: "block"
        };
        _defConf = {
            autodismissdelay: 0,
            opacity: 1,
            closeOnDOMReady: false,
            closeOnLoad: true,
            close: false,
            effect: false,
            simple: false,
            fullscreen: false
        };
        function O(){
            if (D.isObject(K.element)) {
                B.setStyle(K.element, "opacity", 0);
                B.setStyle(K.element, "display", "none")
            }
        }
        function G(){
            if (D.isObject(K.element)) {
                B.setStyle(K.element, "opacity", _defConf.opacity)
            }
        }
        var N = function(S, R){
            if (I && D.isObject(K.element) && ((K.element === R[1].target) || B.isAncestor(K.element, R[1].target))) {
                if (window.confirm("Do you want to hide the loading mask?")) {
                    K.hide()
                }
            }
        };
        C.on("navigate", N);
        C.on("property", N);
        K.counter = 0;
        K.element = null;
        K.content = null;
        K.proxy = null;
        K.anim = null;
        K.config = function(R){
            R = R || {};
            D.augmentObject(_defConf, R, true);
            if (this.element && I) {
                G()
            }
        };
        K.backup = function(){
            var R = document.body;
            Q.padding = B.getStyle(R, "padding");
            Q.margin = B.getStyle(R, "margin");
            Q.overflow = B.getStyle(R, "overflow")
        };
        K.restore = function(){
            var S = document.body, T = document.documentElement;
            B.setStyle(S, "padding", Q.padding);
            B.setStyle(S, "padding", Q.padding);
            B.setStyle(S, "overflow", Q.overflow);
            B.setStyle(S, "height", "auto");
            B.setStyle(S, "width", "auto");
            B.setStyle(T, "overflow", "auto");
            B.setStyle(T, "height", "auto");
            B.setStyle(T, "width", "auto");
            var R = Math.max(B.getViewportHeight(), S.offsetHeight) + "px";
            B.setStyle(S, "height", R);
            B.setStyle(T, "height", R);
            window.setTimeout(function(){
                B.setStyle(S, "height", "auto");
                B.setStyle(T, "height", "auto")
            }, 1)
        };
        K.init = function(){
            var R;
            this.element = E(F);
            this.content = E(L);
            if (!P && (D.isObject(this.element))) {
                P = true;
                for (R in H) {
                    if (H.hasOwnProperty(R)) {
                        B.setStyle(this.element, R, H[R])
                    }
                }
                K.show()
            }
        };
        K.adjust = function(){
            var S;
            if (!_defConf.fullscreen && this.proxy && B.inDocument(this.proxy)) {
                S = B.getRegion(this.proxy);
                S.height = S.bottom - S.top;
                S.width = S.right - S.left
            }
            else {
                S = {
                    top: B.getDocumentScrollTop(),
                    left: B.getDocumentScrollLeft(),
                    width: B.getViewportWidth(),
                    height: B.getViewportHeight()
                }
            }
            if (I) {
                B.setStyle(this.element, "height", S.height + "px");
                B.setStyle(this.element, "width", S.width + "px");
                B.setXY(this.element, [S.left, S.top]);
                if (this.content) {
                    var U = B.getRegion(this.content);
                    var T = U.bottom - U.top;
                    var R = U.right - U.left;
                    B.setXY(this.content, [S.left + ((S.width - R) / 2), S.top + ((S.height - T) / 2)])
                }
            }
        };
        K.show = function(R){
            if (this.element && !I) {
                I = true;
                this.backup();
                this.proxy = R;
                if (!this.proxy || _defConf.fullscreen) {
                    B.setStyle(document.documentElement, "overflow", "hidden");
                    B.setStyle(document.body, "overflow", "hidden")
                }
                B.setStyle(this.element, "display", "block");
                if (M) {
                    C.on("repaint", K.adjust, K, true)
                }
                K.adjust();
                if (_defConf.effect && !M) {
                    if ((this.anim) && (this.anim.isAnimated())) {
                        this.anim.stop()
                    }
                    this.anim = new YAHOO.util.Anim(this.element, {
                        opacity: {
                            to: _defConf.opacity
                        }
                    }, 1.5, YAHOO.util.Easing.easeIn);
                    this.anim.onComplete.subscribe(G);
                    this.anim.animate()
                }
                else {
                    G()
                }
                if (_defConf.closeOnDOMReady) {
                    A.onDOMReady(K.hide, K, true)
                }
                if (_defConf.closeOnLoad) {
                    A.on(window, "load", K.hide, K, true)
                }
                window.clearTimeout(J);
                J = null;
                if (D.isNumber(_defConf.autodismissdelay) && (_defConf.autodismissdelay > 0)) {
                    J = window.setTimeout(function(){
                        K.hide()
                    }, Math.abs(_defConf.autodismissdelay))
                }
            }
        };
        K.hide = function(){
            if (this.element && I) {
                I = false;
                if (_defConf.effect) {
                    if ((this.anim) && (this.anim.isAnimated())) {
                        this.anim.stop()
                    }
                    this.anim = new YAHOO.util.Anim(this.element, {
                        opacity: {
                            to: 0
                        }
                    }, 1.5, YAHOO.util.Easing.easeOut);
                    this.anim.onComplete.subscribe(O);
                    this.anim.animate()
                }
                else {
                    O()
                }
                K.counter = 0;
                K.restore();
                if (M) {
                    M = false;
                    YAHOO.Bubbling.fire("onMaskReady", {
                        element: K.element,
                        content: K.content,
                        config: _defConf
                    })
                }
            }
        };
        if (B.inDocument(F)) {
            K.init()
        }
        else {
            A.onContentReady(F, K.init, K, true)
        }
        if (D.isObject(YAHOO.widget._cLoading)) {
            K.config(YAHOO.widget._cLoading)
        }
        if (!_defConf.simple) {
            C.on("onAsyncRequestStart", function(S, R){
                K.counter++;
                K.show(R[1].element)
            });
            C.on("onAsyncRequestEnd", function(S, R){
                K.counter--;
                if (K.counter <= 0) {
                    K.hide();
                    K.counter = 0
                }
            })
        }
        return K
    }()
})();
YAHOO.register("loading", YAHOO.widget.Loading, {
    version: "2.0",
    build: "218"
});
