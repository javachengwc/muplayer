package {
    import flash.display.Sprite;
    import flash.events.*;
    import flash.errors.IOError;
    import flash.external.ExternalInterface;
    import flash.media.SoundTransform;
    import flash.system.Security;

    import Consts;
    import State;
    import Utils;

    public class BaseCore extends Sprite implements IEngine {
        private var stf:SoundTransform;

        // JS回调
        private var jsInstance:String = '';

        // 实例属性
        protected var _volume:uint = 80;               // 音量(0-100)，默认80
        protected var _mute:Boolean = false;           // 静音状态，默认flase
        protected var _state:int = State.NOT_INIT;     // 播放状态
        protected var _muteVolume:uint;                // 静音时的音量
        protected var _url:String;                     // 外部文件地址
        protected var _length:uint;                    // 音频总长度(ms)
        protected var _position:uint;                  // 当前播放进度(ms)
        protected var _loadedPct:Number;               // 载入进度百分比[0-1]
        protected var _positionPct:Number;             // 播放进度百分比[0-1]
        protected var _pausePosition:Number;           // 暂停时的播放进度(ms)
        protected var _bytesTotal:uint;                // 外部文件总字节
        protected var _bytesLoaded:uint;               // 已载入字节

        // 最小缓冲时间(ms)
        // MP3 数据保留在Sound对象缓冲区中的最小毫秒数。
        // 在开始回放以及在网络中断后继续回放之前，Sound 对
        // 象将一直等待直至至少拥有这一数量的数据为止。
        // 默认值为1000毫秒。
        private var bufferTime:uint = 5000;

        public function BaseCore() {
            Utils.checkStage(this, 'init');
        }

        public function init():void {
            Security.allowDomain('*');
            Security.allowInsecureDomain('*');
            loadFlashVars(loaderInfo.parameters);
            if (ExternalInterface.available) {
                reset();
                stf = new SoundTransform(_volume / 100, 0);
                ExternalInterface.addCallback('load', load);
                ExternalInterface.addCallback('play', play);
                ExternalInterface.addCallback('pause', pause);
                ExternalInterface.addCallback('stop', stop);
                ExternalInterface.addCallback('getData', getData);
                ExternalInterface.addCallback('setData', setData);
                callJS(Consts.SWF_ON_LOAD);
            }
        }

        protected function callJS(fn:String, data:Object = undefined):void {
            Utils.callJS(jsInstance + fn, data);
        }

        protected function loadFlashVars(p:Object):void {
            jsInstance = p['_instanceName'];
            setBufferTime(p['_buffertime'] || bufferTime);
        }

        protected function onPlayComplete(e:Event = null):void {}

        public function handleErr(e:IOErrorEvent):void {
            onPlayComplete();
            callJS(Consts.SWF_ON_ERR, e);
        }

        public function getData(k:String):* {
            var fn:String = 'get' + k.substr(0, 1).toUpperCase() + k.slice(1);
            if (this[fn]) {
                return this[fn]();
            }
        }

        public function setData(k:String, v:*):* {
            var fn:String = 'set' + k.substr(0, 1).toUpperCase() + k.slice(1);
            if (this[fn]) {
                return this[fn](v);
            }
        }

        public function getState():int {
            return _state;
        }

        public function setState(st:int):void {
            if (_state != st && State.validate(st)) {
                _state = st;
                callJS(Consts.SWF_ON_STATE_CHANGE, st);
            }
        }

        public function getBufferTime():uint {
            return bufferTime;
        }

        public function setBufferTime(bt:uint):void {
            bufferTime = bt;
        }

        public function getMute():Boolean {
            return _mute;
        }

        public function setMute(m:Boolean):void {
            if (m) {
                _muteVolume = _volume;
                setVolume(0);
            } else {
                setVolume(_muteVolume);
            }
            _mute = m;
        }

        public function getVolume():uint {
            return _volume;
        }

        public function setVolume(v:uint):void {}

        public function getUrl():String {
            return _url;
        }

        public function getLength():uint {
            return _length;
        }

        public function getPosition():uint {
            return _position;
        }

        public function getLoadedPct():Number {
            return _loadedPct;
        }

        // positionPct和loadedPct都在JS层按需获取，不在
        // AS层主动派发，这样简化逻辑，节省事件开销。
        public function getPositionPct():Number {
            return _positionPct;
        }

        public function getBytesTotal():uint {
            return _bytesTotal;
        }

        public function getBytesLoaded():uint {
            return _bytesLoaded;
        }

        public function reset():void {
            _url = '';
            _length = 0;
            _position = 0;
            _loadedPct = 0;
            _positionPct = 0;
            _pausePosition = 0;
            _bytesTotal = 0;
            _bytesLoaded = 0;
        }

        public function load(url:String):void {}

        public function play(p:Number = 0):void {}

        public function pause():void {}

        public function stop(p:Number = 0):void {}
    }
}
