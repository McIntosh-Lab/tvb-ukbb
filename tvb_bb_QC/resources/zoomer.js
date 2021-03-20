//https://github.com/bearhotel515/image-viewer

class Viewer {
  constructor(canvas, image) {
    this.canvas = canvas
    // 图片
    this.image = image
    // 原始图片
    this.originalImg = image
    this.ctx = this.canvas.getContext('2d')

    /**
    * return {}
    * {} x 图片显示的x坐标
    * {} y 图片显示的y坐标
    * {} w 图片宽度
    * {} h 图片高度
    *
    */
    this.getFitSize = function () {
      let x = 0
      let y = 0
      let w = this.imageW // 图片的宽度
      let h = this.imageH // 图片的高度
      let cw = this.cavW // 画布的宽度
      let ch = this.cavH // 画布的高度
      if (w < cw && h < ch) {
        x = 0.5 * cw - 0.5 * w
        y = 0.5 * ch - 0.5 * h
      } else if (h / w > ch / cw) {
        w = w * ch / h // ()
        h = ch// 图片的高度置成画布高度
        x = 0.5 * cw - 0.5 * w
      } else {
        h = h * cw / w
        w = cw// 图片的宽度置成画布宽度
        y = 0.5 * ch - 0.5 * h
      }
      return {
        x, y, w, h
      }
    }

    this.isNum = function (o) {
      return /^(-?\d+)(\.\d+)?$/.test(o)
    }
    // 初始化
    this.init()
  }

  init() {
    this.initData()
    this.initListener()
  }

  reset() {
    this.resetData()
    this.initListener()
  }

  resetData() {
    let { width: imageW, height: imageH } = this.image
    let { width: cavW, height: cavH } = this.canvas
    // 放大倍数
    this.imgScale = 1
    // 旋转角度
    this.angle = 0
    // 竖向像素反转
    this.isVRevert = 1
    // 横向像素反转
    this.isHRevert = 1
    // 是否移动
    this.isMove = false
    // 图片的宽度
    this.imageW = imageW
    // 图片的高度
    this.imageH = imageH
    // 画布的宽度
    this.cavW = cavW
    // 画布的高度
    this.cavH = cavH
    let size = this.getFitSize()
    this.imgX = 0 //size.x
    this.imgY = 0.5 * this.cavH - 0.5 * size.h * (this.cavW/size.w) //size.y
    //this.image = this.originalImg
  }


  setimage(image){
    this.image=image;
  }
  initData() {
    let { width: imageW, height: imageH } = this.image
    let { width: cavW, height: cavH } = this.canvas
    // 放大倍数
    this.imgScale = 1
    // 旋转角度
    this.angle = 0
    // 竖向像素反转
    this.isVRevert = 1
    // 横向像素反转
    this.isHRevert = 1
    // 是否移动
    this.isMove = false
    // 图片的宽度
    this.imageW = imageW
    // 图片的高度
    this.imageH = imageH
    // 画布的宽度
    this.cavW = cavW
    // 画布的高度
    this.cavH = cavH
    let size = this.getFitSize()
    this.imgX = 0 //size.x
    this.imgY = 0.5 * this.cavH - 0.5 * size.h * (this.cavW/size.w) //size.y
    this.image = this.originalImg
  }

  // 初始化监听
  initListener() {
    this.canvas.addEventListener('mousedown', this, false)
    this.canvas.addEventListener('mouseup', this, false)
    this.canvas.addEventListener('mouseout', this, false)
    this.canvas.addEventListener('mousewheel', this, false)
  }

  handleEvent(e) {
    switch (e.type) {
      case 'mousemove':
        this.mousemove(e)
        break
      case 'mousewheel':
        this.mousewheel(e)
        break
      case 'mouseup':
        this.mouseup(e)
        break
      case 'mousedown':
        this.mousedown(e)
        break
      case 'mouseout':
        this.mouseout(e)
        break
    }
  }
  mouseout() {
    this.isMove = false
    this.canvas.style.cursor = 'default '
    this.canvas.removeEventListener('mousemove', this, false)
  }

  // 鼠标按下
  mousedown(event) {
    this.mouseDownPos = this.windowToCanvas(event.clientX, event.clientY)
    this.isMove = true
    this.canvas.style.cursor = 'move'
    this.canvas.addEventListener('mousemove', this, false)
  }

  // 鼠标抬起
  mouseup() {
    this.isMove = false
    this.canvas.style.cursor = 'default '
    this.canvas.removeEventListener('mousemove', this, false)
  }

  // 鼠标移动
  mousemove(event) {
    if (!this.isMove) {
      return
    }
    let pos = this.mouseDownPos
    this.canvas.style.cursor = 'move'
    let pos1 = this.windowToCanvas(event.clientX, event.clientY)
    let x = pos1.x - pos.x
    let y = pos1.y - pos.y
    this.mouseDownPos = pos1
    this.imgX += x
    this.imgY += y
    // drawImage()
    this.draw()
  }

  // 监听canvas放大缩小事件
  mousewheel(event) {
    let pos = this.windowToCanvas(event.clientX, event.clientY)
    let _wheelDelta = event.wheelDelta ? event.wheelDelta : (event.deltaY * (-40))
    if (_wheelDelta > 0) { // 放大
      this.imgScale *= 2
      this.imgX = this.imgX * 2 - pos.x
      this.imgY = this.imgY * 2 - pos.y
    } else {
      this.imgScale /= 2
      this.imgX = this.imgX * 0.5 + pos.x * 0.5
      this.imgY = this.imgY * 0.5 + pos.y * 0.5
    }
    this.draw()
  }
  scale(num) {
    if (this.isNum(num)) {
      this.imgScale *= num

      

      if (num>1){
        this.imgX = this.imgX * num - this.cavW * (1 - 1/(num))/2
        this.imgY = this.imgY * num - this.cavH * (1 - 1/(num))/2
      }

      if (num<1){
        this.imgX = this.imgX * num + this.cavW * (1 - (num))/2
        this.imgY = this.imgY * num + this.cavH * (1 - (num))/2
      }

      
      this.draw()
    }
  }
  // 设置成原始尺寸
  setOriginalSize() {
    let size = this.getFitSize()
    this.imgScale = this.originalImg.width / size.w
    let pos = {
      x: this.cavW / 2 - this.originalImg.width / 2,
      y: this.cavH / 2 - this.originalImg.height / 2
    }
    if (this.imgScale > 1) { // 放大
      this.imgX = pos.x * this.imgScale
      this.imgY = pos.y * this.imgScale
    } else {
      this.imgX = pos.x / this.imgScale
      this.imgY = pos.y / this.imgScale
    }
    this.draw()
  }
  // 销毁
  dstroy() {
    this.canvas.removeEventListener('mousedown', this, false)
    this.canvas.removeEventListener('mouseout', this, false)
    this.canvas.removeEventListener('mousewheel', this, false)
    this.canvas.removeEventListener('mouseup', this, false)
    this.canvas.removeEventListener('mousemove', this, false)
    this.canvas = null
    this.image = null
  }

  // 获取窗口中canvas的区域
  windowToCanvas(x, y) {
    let bbox = this.canvas.getBoundingClientRect()
    return {
      x: x - bbox.left - (bbox.width - this.cavW) / 2,
      y: y - bbox.top - (bbox.height - this.cavH) / 2
    }
  }

  // 清空
  clearCanvas() {
    this.ctx.clearRect(0, 0, this.cavW, this.cavH)
  }

  /**
   * 画
   * x 图片的位置
   * y 图片的位置
   * w 图片的宽
   * h 图片的高
   *
   * */
  renderImage(x, y, w, h) {
    this.clearCanvas()
    this.ctx.save()
    this.ctx.fillStyle = 'white'
    this.ctx.fill()
    this.ctx.translate(x + w / 2, y + h / 2)
    this.ctx.rotate(this.angle)
    this.ctx.scale(this.isHRevert, this.isVRevert)
    this.ctx.drawImage(this.image, 0, 0, this.imageW, this.imageH, -w / 2, -h / 2, w, h)
    this.ctx.restore()
  }

  // 旋转角度
  rotate(rad) {
    this.angle += rad
    this.draw()
  }

  // 垂直镜像
  vRevert() {
    this.isVRevert *= -1
    this.draw()
  }

  // 水平镜像
  hRevert() {
    this.isHRevert *= -1
    this.draw()
  }
  draw() {
    let size = this.getFitSize()


    size.h=size.h * (this.cavW/size.w)  //added
    size.w=this.cavW                    //added

    this.renderImage(this.imgX, this.imgY, size.w * this.imgScale, size.h * this.imgScale)
  }
}