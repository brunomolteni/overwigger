<device style="color: {this.channel ? `rgba(${this.channel.color.r},${this.channel.color.g},${this.channel.color.b},${this.channel.color.a})` : '#414141'}">

  <virtual if={this.channel}>
    <div class="macros">
      <knob each={macro, index in this.channel.macros} i={index} name={macro.name === '' ? '✖' : macro.name } val={macro.value} position={index}></knob>
    </div>
    <div class="title">
      <span onclick={ select } title="Select this Track">{this.channel.name === '' ? '--' : this.channel.name}</span>
      <i if={true || this.channel.overriden} onclick={ restore } title="Restore Automation">●</i>
    </div>
    <!-- <piano track={opts.track-1}></piano> -->
  </virtual>

  <script>
    const trackNumber = this.opts.track-1;
    this.macros = i => this.tags.knob[i];

    this.select = () => primus.write({track: trackNumber, select: true});

    this.restore = () => primus.write({track: trackNumber, restore: true})

    primus.on('data', data => {
      if(data.channels && data.channels[trackNumber]){
        this.channel = data.channels[trackNumber];
        this.update();
      }
      else if(typeof data.track !== 'undefined' && data.track===trackNumber){
        if(typeof data.macro !== 'undefined' ){
          if(typeof data.value !== 'undefined' ){
            this.macros(data.macro).trigger('value',data.value);
            return;
          };
          if(data.name) this.channel.macros[data.macro].name = data.name;
        }
        else {
          if(data.name) this.channel.name = data.name;
          if(data.color) this.channel.color = convertColorObj(data.color);
        }
        console.log(this.channel.color);
        this.update();
      }
    });

    function convertColorObj(color){
      let {r,g,b} = color;
      console.log(r);
      return {r: scaleColor(r), g: scaleColor(g), b: scaleColor(b)}
    }

    function scaleColor(unscaledNum) {
      return Math.floor( (255 - 0) * (unscaledNum - 0) / (1 - 0) + 0);
    }
  </script>

  <style>
    :scope{
      --device-height: calc(40vh);
      background-color: #414141;
      border-radius: 6px;
      height: var(--device-height);
      display: flex;
      flex-direction: column;
      touch-action: none;
      overflow: hidden;
      flex-grow: 1;
      width: 24%;
      margin: 4px ;
      position: relative;
      min-width: 200px;
    }
    .title{
      width: 100%;
      color: white;
      text-transform: uppercase;
      overflow: hidden;
      font-weight: bold;
      font-size: 16px;
      color: #bbb;
      line-height: 30px;
      display: flex;
      justify-content: space-between;
      position: relative;
    }
    .title > span{
      white-space: nowrap;
      text-overflow: ellipsis;
      width: 80%;
      overflow: hidden;
      padding: 10px;
      flex-grow: 0;
      cursor: pointer;
    }

    .title > i{
      position: absolute;
      right: 0;
      bottom: 0;
      font-size: 30px;
      line-height: 35px;
      padding: 10px;
      cursor: pointer;
      text-align: right;
      /* display: none; */
    }
    .macros{
      border: 4px solid #515151;
      flex: 1;
      display: flex;
      flex-wrap: wrap;
    }
    piano{
      position: absolute;
      bottom: 0;
      z-index: 100;
    }
  </style>

</device>
