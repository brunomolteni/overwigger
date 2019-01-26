<knob>

  <input type="range" ref="input" min="0" max="127" class={ 'i'+this.opts.i } oninput={ moving } onchange={ finishMoving }>
  <p class="name" onclick={ reset }>{this.opts.name}</p>

  <script>
    const trackNumber = this.parent.opts.track-1;
    this.moving = throttle(e => {
      primus.write({track: trackNumber, macro: this.opts.i, value: +e.target.value});
    },50);

    this.finishMoving = throttle(e => {
      primus.write({track: trackNumber, macro: this.opts.i, value:'release'});
    },50);

    this.on('mount', ()=>{
      this.refs.input.value = this.scaledVal(this.opts.val);
    });

    this.on('value', val => {
      this.refs.input.value = this.scaledVal(val);
    });

    this.scaledVal = (val) => {
      return Math.floor( (127 - 0) * (val - 0) / (1 - 0) + 0);
    };

    function debounce(callback, wait, context = this) {
      let timeout = null
      let callbackArgs = null

      const later = () => callback.apply(context, callbackArgs)

      return function() {
        callbackArgs = arguments
        clearTimeout(timeout)
        timeout = setTimeout(later, wait)
      }
    }


    function throttle (callback, limit) {

      var wait = false;
      return function () {
        if (!wait) {

          callback.apply(null, arguments);
          wait = true;
          setTimeout(function () {
            wait = false;
          }, limit);
        }
      }
    }

  </script>


  <style>
    :scope{
      border: 2px solid #515151;
      width: 25%;
      box-sizing: border-box;
      display: flex;
      justify-content: center;
      align-items: center;
      position: relative;
      overflow: hidden;
      background: transparent;
      z-index: 1;

    }
    :scope::after{
      content: '';
      display: block;
      width: 100%;
      height: 30px;
      position: absolute;
      bottom: 0;
      background-image: linear-gradient(to bottom, transparent, rgba(0,0,0,0.4));
      z-index: 0;
      pointer-events: none;
      /* background-color: currentColor; */
    }

    .name{
      position: absolute;
      bottom: 0;
      margin: 0;
      height: 45px;
      z-index: 2;
      text-align: center;
      line-height: 45px;
      /* font-weight: bold; */
      font-size: 12px;
      color: white;
      text-shadow: 0 1px 0 rgba(0,0,0,0.5), 1px 0 0 rgba(0,0,0,0.5), 0 -1px 0 rgba(0,0,0,0.5), -1px 0 0 rgba(0,0,0,0.5);
      pointer-events: none;
      width: 90%;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    input{
      transform: rotate(-90deg) translateY(-90px);
      transform-origin: right top;
      position: relative;
      height: 90px;
      backface-visibility: hidden;
      -webkit-appearance: none;
      width: calc(var(--device-height) - 56px);
      margin: 0;
      position: absolute;
      top: -5px;
      right: -5px;
      left: auto;
      border: none;
      background: transparent;
      color: currentColor;
    }
    input:focus{
      outline: 0;
      outline: none!important;
    }
    input[type=range]::-webkit-slider-runnable-track {
      width: 10px;
      height: 200px;
      cursor: pointer;
      background-color: currentColor !important;
      background-image: linear-gradient(to right, transparent, rgba(0,0,0,0.4));
    }
    input[type=range]::-webkit-slider-thumb {
      height: 200px;
      width: 50px;
      background-color: rgba(80,80,80,0.5);
      color
      cursor: pointer;
      -webkit-appearance: none;
      margin-top: 0px;
      position: relative;
      box-shadow: 1000px 0 0 1000px rgba(0,0,0,0.8), 0 10px 15px rgba(0,0,0,0.6);
      background-image: linear-gradient(to right, transparent, rgba(255,255,255,0.2));
      opacity: 0.8;
      outline: 2px solid rgba(0,0,0,0.6);
    }
    /* input.i0[type=range]::-webkit-slider-thumb:after{
      outline-color: #d41734;
    }
    input.i1[type=range]::-webkit-slider-thumb{
      outline-color: #f67c19;
    }
    input.i2[type=range]::-webkit-slider-thumb{
      outline-color: #f3e324;
    }
    input.i3[type=range]::-webkit-slider-thumb{
      outline-color: #5bc515;
    }
    input.i4[type=range]::-webkit-slider-thumb{
      outline-color: #65cc91;
    }
    input.i5[type=range]::-webkit-slider-thumb{
      outline-color: #5ca7ed;
    }
    input.i6[type=range]::-webkit-slider-thumb{
      outline-color: #c16dfc;
    }
    input.i7[type=range]::-webkit-slider-thumb{
      outline-color: #cc348b;
    } */
  </style>

</knob>
