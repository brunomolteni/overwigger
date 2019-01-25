<device style="color: {this.channel ? `rgba(${this.channel.color.r},${this.channel.color.g},${this.channel.color.b},${this.channel.color.a})` : '#414141'}">

  <virtual if={this.channel}>
    <div class="title">{this.channel.name === '' ? '--' : this.channel.name}</div>
    <div class="macros">
      <knob each={macro, index in this.channel.macros} i={index} name={macro.name === '' ? '✖' : macro.name } val={macro.value} position={index}></knob>
    </div>
    <!-- <piano track={opts.track-1}></piano> -->
  </virtual>

  <script>
    primus.on('data', d => {
      var data = JSON.parse(d);

      if(data.channels && data.channels[this.opts.track-1]){
        this.channel = data.channels[this.opts.track-1];
        this.update();
      }

      if(typeof data.macro !== 'undefined' && data.track===this.opts.track-1){
        var macro = this.tags.knob[data.macro];

        if(typeof data.value !== 'undefined' ) macro.trigger('value',data.value);
        if(data.name) this.channel.macros[data.macro].name = data.name, this.update();
      }
    });
  </script>

  <style>
    :scope{
      --device-height: calc(50vh - 20px - 8px - 10px);
      background-color: #414141;
      border-radius: 6px;
      height: var(--device-height);
      display: flex;
      flex-direction: row;
      /* padding-left: 30px; */
      padding-bottom: 20px;
      touch-action: none;
      overflow: hidden;
      flex-grow: 0;
      width: 24%;
      margin: 4px ;
      position: relative;
      min-width: 200px;
    }
    .title{
      /* flex: 0; */
      bottom: -4px;
      /* transform: rotate(-90deg) translateX( calc( -1 * var(--device-height) ) ) translateY(-30px); */
      backface-visibility: hidden;
    	transform-origin:  left top 0;
      /* width: var(--device-height); */
      width: 100%;
      color: white;
      text-transform: uppercase;
      overflow: hidden;
      font-weight: bold;
      font-size: 12px;
      color: #bbb;
      white-space: nowrap;
      line-height: 30px;
      position: absolute;
      text-align: center;
      white-space: nowrap;
      text-overflow: ellipsis;
    }
    .macros{
      border: 4px solid #515151;
      flex: 1;
      display: flex;
      flex-wrap: wrap;
    }
    knob:nth-child(){
      display: none;
    }
    piano{
      position: absolute;
      bottom: 0;
      z-index: 100;
    }
  </style>

</device>
