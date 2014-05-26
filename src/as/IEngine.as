package {
    public interface IEngine {
        function getState():int;

        function setState(st:int):void;

        function getBufferTime():uint;

        function setBufferTime(bt:uint):void;

        function getMute():Boolean;

        function setMute(m:Boolean):void;

        function getVolume():uint;

        function setVolume(v:uint):void;

        function getUrl():String;

        function getLength():uint;

        function getPosition():uint;

        function getLoadedPct():Number;

        function getPositionPct():Number;

        function getBytesTotal():uint;

        function getBytesLoaded():uint;

        function load(url:String):void;

        function play(p:Number = 0):void;

        function pause():void;

        function stop(p:Number = 0):void;
    }
}
