if(undefined==window.PComments){window.PComments={}}
$.extend(window.PComments,{
  // Voter UP pour un commentaire de page
  upvote: function(cid){
    Ajax.send({
      route     : 'page_comments/'+cid+'/vote?in=site',
      vote      : 'up',
      onreturn  : $.proxy(PComments,'retourvote',cid,'up')
    })
  },
  // Voter DOWN pour un commentaire de page
  downvote: function(cid){
    Ajax.send({
      route     : 'page_comments/'+cid+'/vote?in=site',
      vote      :'down',
      onreturn  : $.proxy(PComments,'retourvote',cid,'down')
    })
  },
  retourvote:function(cid, sens, rajax){
    if(rajax.vote_ok){
      $('li#li_pcomment-'+cid+' span.'+sens+'votes').html(rajax.votes_newvalue)
    }
  }
})
