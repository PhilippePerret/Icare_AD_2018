const WITH_MILLIEME   = 1;
const HOUR_TWO_DIGITS = 2;
window.Time = {
  
  // Format de l'horloge
  // @valeurs possibles :
  //    null                => H:MM:SS
  //    'with_milliemes'    => H:MM:SS,MMM
  
  FORMAT_HORLOGE_DEFAULT: WITH_MILLIEME,
  
  // Retourne le temps courant
  // Pour le moment, le nombre de microsecondes ou le format local
  // si format est défini
  now:function(format){
    if(undefined == format) return (new Date()).valueOf();
    else return new Date().toLocaleString();
  },
  /*
   *  Retourne le nombre de minutes pour l'horloge donnée
   *  
   */
  horlogeToMinutes:function(val)
  {
    return parseInt(this.h2s(val) / 60, 10)
  },
  h2m:function(val){return this.horlogeToMinutes(val)},
  /*
   *  Retourne l'horloge en fonction du nombre de minutes
   *  fourni.
   *  
   */
  minutesToHorloge:function(mns, options)
  {
    if(undefined == options) options = {}
    if(undefined == options.no_frames) options.no_frames = true
    return this.secondsToHorloge( parseInt(mns,10) * 60, options )
  },
  m2h:function(mns, options){return this.minutesToHorloge(mns, options)},
  // Retourne le nombre de secondes (float) en fonction de l'horloge
  // fournie.
  // @note: Si l'horloge contient un point, c'est un time code
  horlogeToSeconds:function(val){
    var hrl, frames = 0;
    if(val.indexOf(',')>-1){
      var p = val.split(',')
      hrl = p[0];
      frames = parseInt(p[1],10);
    } else { hrl = val }
    hrl = hrl.split(':').reverse();
    var seconds = parseInt(hrl[0]||0,10) + (hrl[1]||0)*60 + (hrl[2]||0)*3600;
    return parseFloat(seconds) + frames/1000;
  },
  h2s:function(val){return this.horlogeToSeconds(val)},
  /*
      Reçoit un nombre de secondes et retourne une horloge
      -------------------------------------------------------------------
      @param    val       Nombre de secondes (float / integer)
      @param    options   Liste optionnelle d'options :
                          hour_2_digits     Si true, met l'heure en format de 2 chiffres
                                            False par défaut.
  */
  secondsToHorloge:function(val,options){
    if('undefined'==typeof options)options = {}
    var fms="000";
    if(undefined == val || val === null) return "x:xx:xx";
    if(val.toString().indexOf(".")>-1){
      val = val.toString().split('.');
      fms = parseInt(val[1],10).toString().substring(0,3);
      while(fms.toString().length < 3) fms += "0";
      val = parseInt(val[0],10);
    }
    var hrs = Math.floor(val / 3600);
    if((options.hour_2_digits || (this.FORMAT_HORLOGE_DEFAULT & HOUR_TWO_DIGITS)) && hrs < 10) hrs = "0"+hrs;
    var reste = val % 3600;
    var mns = Math.floor(reste / 60);
    if(mns < 10) mns = "0"+mns;
    var scs = (reste % 60) * 1000;
    scs = Math.floor(scs/1000);
    if(scs<10) scs = "0"+scs
    var h = hrs+":"+mns+":"+scs
    if(options.no_frames) return h
    if(this.FORMAT_HORLOGE_DEFAULT & WITH_MILLIEME) h += ","+fms;
    return h;
  },
  s2h:function(val,options){return this.secondsToHorloge(val,options)},
  /**
    * Retourne un objet décomposant le temps +time+
    * @method decompose
    * @param {Number} msecs   Le nombre de millisecondes
    * @return {Object} définissant :
    *   only_mls    Seulement les millisecondes
    *   mls         Total des millisecondes (en fait = time)
    *   only_scs    Seulement le nombre de secondes
    *   scs         Le nombre de secondes total dans +time+
    *   only_mns    Seulement le nombre de minutes
    *   mns         Le nombre total de minutes dans +time+
    *   only_hrs    Seulement le nombre d'heures (en fait = hrs)
    *   hrs         Le nombre d'heures total dans +time+
    */
  decompose:function(time)
  {
    var only_seconds  = Math.floor(time / 1000)
    var msecs         = time % 1000
    var only_minutes  = Math.floor(only_seconds / 60)
    var seconds       = only_seconds % 60
    var only_hours    = Math.floor(only_minutes / 60)
    var minutes       = only_minutes % 60
    return {
      only_mls: time,
      only_scs: only_seconds,
      only_mns: only_minutes,
      only_hrs: only_hours,
      mls : msecs,
      scs : seconds,
      mns : minutes,
      hrs : only_hours
    }
  }
}

// Format d'horloge par défaut : H:MM:SS
Time.FORMAT_HORLOGE_DEFAULT = null;
