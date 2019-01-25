<piano>

<div no-reorder each={ item, i in items} class={playing: !!item.playing, black: item.i === 1 || item.i === 3 || item.i === 6 || item.i === 8 || item.i === 10}>
▌
</div>

<script>

this.on('before-mount', function(){
  this.items = new Array(12).fill({}, 0, 12).map( (el,i) => ({playing: false,i: i}) );
  console.log(this.items);
});

primus.on('data', d => {
  var data = JSON.parse(d);

  if(data.note && data.track === +opts.track ){
    this.items = this.items.map( (el) => {
      if(el.i === data.note.key % 12) return {playing: data.note.noteOn, i: el.i};
      else return el;
    })
    setTimeout(this.update,1);
    console.log(this.items);
  }
});
</script>

<style>
  :scope{
    position: relative;
    display: block;
  }
  div{
    color: white;
    display: inline;
  }
  .black{
    color: #333;
    position: absolute;
    top: -1em;
    transform: translateX(-10px);
  }
  .playing{
    color: red;
  }
</style>
</piano>
