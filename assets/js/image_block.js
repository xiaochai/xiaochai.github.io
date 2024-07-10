function gen_desc_image(src, desc){
    return '<div class="image-sec"><img src="'+src+'" /></div>'+
    '<div class="desc-sec"><span>'+desc+'</span></div>'
}

function gen_image_block_in_two(src1, desc1, src2, desc2, width){
    return '<div class="image-block-in-two">'+
    '<div class="image-block-with-desc" style="flex-grow: 0;flex-shrink: 0;width: '+width+'">'+
    gen_desc_image(src1, desc1)+
    '</div>'+
    '<div style="width:60px"></div>'+
    '<div class="image-block-with-desc">'+
    gen_desc_image(src2, desc2)+
    '</div>'
}

$(document).ready(function(){
  $(".image-block-with-desc").each(function(){
    var src = $(this).data("image-src");
    var desc = $(this).data("desc") === undefined ? "" : $(this).data("desc");
    var html = gen_desc_image(src, desc);
    $(this).html(html);
  })
  $(".image-block-in-two").each(function(){
    var src1 = $(this).data("image-src1");
    var desc1 = $(this).data("desc1") === undefined ? "" : $(this).data("desc1");
    var src2 = $(this).data("image-src2");
    var desc2 = $(this).data("desc2") === undefined ? "" : $(this).data("desc2");
    var width = $(this).data("width");
    var html = gen_image_block_in_two(src1, desc1, src2, desc2, width);
    $(this).html(html);
    })

  $(".tooltip").each(function(){
    var tooltip_content = $(this).data("tip");
    if (tooltip_content === undefined) {
      return;
    }
    var html = '<span class="tooltiptext">'+tooltip_content+'</span>'
    $(this).append(html)
  })
})