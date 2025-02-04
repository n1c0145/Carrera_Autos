import peasy.*; // Importar la libreria Peasy Cam

// Variables globales
PImage portada, portada2;
PImage policia, taxi, hummer;
PImage asfalto;
boolean enMenu = true;
boolean enSeleccion = false;
boolean enJuego = false;
boolean enGameOver = false; 
int vehiculoSeleccionado = 0;


PeasyCam cam; // objeto cam
int anchoVentana = 1280;
int altoVentana = 720;

// Variables para el jugador
float jugadorX = 0;
float jugadorZ = 100;
float velocidadJugador = 8;
float limiteCarreteraX = 300;

// Variables para el juego
int numObstaculos = 3; 
float[] obstaculoX = new float[numObstaculos];
float[] obstaculoZ = new float[numObstaculos];
PShape[] modelosAutos = new PShape[numObstaculos];
float velocidadObstaculos = 5;
PShape[] modelosAutosJugador = new PShape[3]; // arreglo para modelos de jugador
float carreteraAncho = 800;
float carreteraLargo = 1200;
float carrilAncho = carreteraAncho / 3;

float desplazamientoLineas = 0;

// Imagen de fondo
PImage fondo;

// Variables para la puntuacion y el tiempo
int puntuacion = 0;
int puntuacionAnterior = 0;
int tiempoInicial;
int tiempoActual;
int tiempoTranscurrido;
int tiempoPuntuacion;

PShape vehiculoSeleccionadoShape; 

float velocidadMinima = 5;

// Arreglo para almacenar los modelos de autos
PShape[] autos = new PShape[5];

void settings() {
  size(anchoVentana, altoVentana, P3D); // configuracion ventana
}

void setup() {
  portada = loadImage("portada.jpg");
  portada2 = loadImage("portada2.jpg");
  policia = loadImage("policia.jpg");
  taxi = loadImage("taxi.jpg");
  hummer = loadImage("hummer.jpg");
  asfalto = loadImage("asfalto.jpg");  
  
  //inicializar camara
  cam = new PeasyCam(this, 100);
  cam.lookAt(650, 400, 600);
  cam.setMinimumDistance(0);
  cam.setMaximumDistance(400);

  fondo = loadImage("ciudad.jpg");
  
  //cargar modelos jugador
  modelosAutosJugador[0] = loadShape("Taxi.obj");
  modelosAutosJugador[1] = loadShape("Cop.obj");
  modelosAutosJugador[2] = loadShape("Humvee.obj");


  for (int j = 0; j < 5; j++) {
    autos[j] = loadShape("Car" + (j + 1) + ".obj");
  }

  // Inicializar posiciones de los obstaculos
  for (int i = 0; i < numObstaculos; i++) {
    reiniciarAuto(i);
  }

  tiempoInicial = millis();
  tiempoPuntuacion = 0;
}


//logica para el menu
void draw() {
  if (enMenu) {
    mostrarMenu();
    cam.setActive(false);  
  } else if (enSeleccion) {
    mostrarSeleccion();
    cam.setActive(false);  
  } else if (enJuego) {
    jugar();
    cam.setActive(true);   
  } else if (enGameOver) {
    mostrarGameOver();
    cam.setActive(false);  
  }
  
  
  println(frameRate);
}

 
void mostrarMenu() {
  // Asegurarse de que la imagen ocupe más del 100% de la pantalla
  float escala = 1.2;  // 120% de la pantalla
  
  // Ajustamos la imagen para que cubra el 120% de la pantalla
  imageMode(CENTER);
  image(portada, width / 2, height / 2, width * escala, height * escala);  // Centra la imagen y la escala al 120%

  textSize(60);
  textAlign(CENTER, CENTER);

  fill(120);
  noStroke();
  rectMode(CENTER);
  rect(width / 2, height / 1.3, 220, 80, 20);

  fill(255);
  text("INICIAR", width / 2, height / 1.3);
}

//metodo seleccion de auto
void mostrarSeleccion() {
  image(portada2, 0, 0, width, height);
  
  textSize(48);
  fill(255);
  textAlign(CENTER, CENTER);
  text("Escoge tu vehiculo", width / 2, height / 6);
  
  float[] posiciones = {width / 4, width / 2, 3 * width / 4};
  imageMode(CENTER);
  for (int i = 0; i < 3; i++) {
    float x = posiciones[i];
    float baseWidth = (dist(mouseX, mouseY, x, height / 2) < 100) ? 300 : 280;
    float baseHeight = baseWidth * 0.75; 
    
    
    //deterrmina el vehiculo a escoger
    PImage vehiculo;
    switch(i) {
      case 0:
        vehiculo = taxi;
        break;
      case 1:
        vehiculo = policia;
        break;
      default:
        vehiculo = hummer;
        break;
    }
    image(vehiculo, x, height / 2, baseWidth, baseHeight);
  }
  imageMode(CORNER);
}


//metodo que determina la seleccion del vehiculo
void mousePressed() {
  if (enMenu && dist(mouseX, mouseY, width / 2, height / 1.3) < 110) {
    enMenu = false;
    enSeleccion = true;
  }

  if (enSeleccion) {
    float[] posiciones = {width / 4, width / 2, 3 * width / 4};
    for (int i = 0; i < 3; i++) {
      float x = posiciones[i];
      if (dist(mouseX, mouseY, x, height / 2) < 100) {
        vehiculoSeleccionado = i; // Cambiar a 0, 1, 2
        enSeleccion = false;
        enJuego = true;

        // Cargar el modelo del vehiculo seleccionado
        vehiculoSeleccionadoShape = modelosAutosJugador[vehiculoSeleccionado];
      }
    }
  }

//pantalla gameover
   if (enGameOver && dist(mouseX, mouseY, width / 2, height / 1.3) < 110) {
    // Cambiar al estado de selección de vehículo
    enGameOver = false;
    enSeleccion = true;
    puntuacion = 0; // Resetear puntuación

    // Reiniciar posiciones de los autos
    for (int i = 0; i < numObstaculos; i++) {
      reiniciarAuto(i);
    }
}
}

//juego
void jugar() {
  background(50, 50, 50);

//pared fondo
  pushMatrix();
  translate(600, -1000, -3000);
  noStroke();
  rectMode(CENTER);
  float anchoPared = 12000;
  float altoPared = 4000;
  fill(50);
  rect(0, 0, anchoPared, altoPared);
  imageMode(CENTER);
  image(fondo, 0, 0, anchoPared, altoPared);
  popMatrix();

// Dibujar la carretera con textura 
pushMatrix();
translate(width / 2, height, 0);
noStroke();
rotateX(PI / 2);

  
int repeticionesY = 7; 

float seccionLargo = (carreteraLargo * 10) / repeticionesY; // Largo de cada sección de la carretera

for (int i = 0; i < repeticionesY; i++) {
  float zInicio = -carreteraLargo * 5 + i * seccionLargo;
  float zFin = zInicio + seccionLargo;
  
  beginShape();
  texture(asfalto);
  
  // Mapeo de textura
  vertex(-carreteraAncho / 2, zInicio, 0, 0);
  vertex( carreteraAncho / 2, zInicio, asfalto.width, 0);
  vertex( carreteraAncho / 2, zFin, asfalto.width, asfalto.height);
  vertex(-carreteraAncho / 2, zFin, 0, asfalto.height);
  
  endShape(CLOSE);
}

popMatrix();


  // Bordes carretera
  pushMatrix();
  translate(width / 2 - carreteraAncho / 2 - 15, height, 0);
  fill(255);
  noStroke();
  rotateX(PI / 2);
  rect(0, 0, 30, carreteraLargo * 10);
  popMatrix();

  pushMatrix();
  translate(width / 2 + carreteraAncho / 2 + 15, height, 0);
  fill(255);
  noStroke();
  rotateX(PI / 2);
  rect(0, 0, 30, carreteraLargo * 10);
  popMatrix();

  // Dibujar lineas carriles
  for (int i = -1; i <= 1; i += 2) {
    pushMatrix();
    translate(width / 2 + i * (carrilAncho / 2), height, 0);
    fill(255);
    noStroke();
    rotateX(PI / 2);

    for (int j = -10; j < 10; j++) {
      if (j % 2 == 0) {
        rect(0, j * 300 + desplazamientoLineas, 3, 150);
      }
    }
    popMatrix();
  }

  desplazamientoLineas += velocidadObstaculos;
  if (desplazamientoLineas >= 500) {
    desplazamientoLineas = 0;
  }

  // Dibujar veredas y postes de luz
  drawSidewalksAndLamps();



  // jugador
  pushMatrix();
  translate(width / 2 + jugadorX, height - 50, jugadorZ);
  // condicional de escala
  if (vehiculoSeleccionado == 0 || vehiculoSeleccionado == 1) {  
    scale(40);  // Escala para Taxi y PolicÃ­a
  } else if (vehiculoSeleccionado == 2) {  
    scale(0.5);  
  }
  rotateX(PI); 
  shape(vehiculoSeleccionadoShape); 
  popMatrix();

  // Obstaculos
  for (int i = 0; i < numObstaculos; i++) {
    pushMatrix();
    translate(width / 2 + obstaculoX[i], height - 50, obstaculoZ[i]);
    scale(40);
    rotateX(PI);
    shape(autos[i]);  // usar arreglo de obstaculos
    popMatrix();

    obstaculoZ[i] += velocidadObstaculos;

    // Reiniciar auto cuando sale de la pantalla
    if (obstaculoZ[i] > 300) {
      obstaculoZ[i] = -5000; 
      obstaculoX[i] = random(-carreteraAncho / 2 + carrilAncho / 2, carreteraAncho / 2 - carrilAncho / 2);
      obstaculoX[i] = round(obstaculoX[i] / carrilAncho) * carrilAncho; 
      int modeloAleatorio = int(random(5));
      autos[i] = autos[modeloAleatorio]; 
    }

// Detectar colisión
if (dist(jugadorX, jugadorZ, obstaculoX[i], obstaculoZ[i]) < 50) {
  // Restablecer la cámara
  cam = new PeasyCam(this, 100);  
  cam.lookAt(650, 400, 600);  
  cam.setMinimumDistance(0); 
  cam.setMaximumDistance(400);  
  
  delay(500);

  enJuego = false;
  enGameOver = true;
}
  }

  // Controles del jugador
  if (keyPressed) {
    if (keyCode == LEFT && jugadorX > -limiteCarreteraX) {
      jugadorX -= velocidadJugador;
    }
    if (keyCode == RIGHT && jugadorX < limiteCarreteraX) {
      jugadorX += velocidadJugador;
    }
    if (keyCode == UP) {
      velocidadObstaculos += 0.1;
    }
    if (keyCode == DOWN) {
      velocidadObstaculos -= 0.5;
      if (velocidadObstaculos < 1) {
        velocidadObstaculos = 1;
      }
    }
  }

  // Calcular tiempo y puntuacion
  tiempoActual = millis();
  tiempoTranscurrido = (tiempoActual - tiempoInicial) / 1000;

  if (tiempoTranscurrido > tiempoPuntuacion) {
    puntuacionAnterior = puntuacion;
    puntuacion += 1 + int((velocidadObstaculos - velocidadMinima) / 2);

    if (puntuacion < puntuacionAnterior) {
      puntuacion = puntuacionAnterior;
    }

    tiempoPuntuacion = tiempoTranscurrido;
  }

  // Mostrar puntuacion y velocidad
  pushMatrix();
  translate(width - 300, 100, 0);
  fill(255);
  noStroke();
  textSize(35);
  textAlign(LEFT, CENTER);
  text("Puntuación: " + puntuacion, 0, 0);
  float velocidadKmh = map(velocidadObstaculos, 1, 20, velocidadMinima, 50);
  text("Velocidad: " + nf(velocidadKmh, 0, 1) + " km/h", 0, 30);
  popMatrix();
}

void drawSidewalksAndLamps() {
  // Luz ambiental general
  ambientLight(100, 100, 100);
  
  // Luz direccional para focos
  directionalLight(255, 255, 200, 0, -1, -0.5);

  // Dibujar veredas
  for (int j = -1; j <= 1; j += 2) {
    pushMatrix();
    translate(width / 2 + j * (carreteraAncho / 2 + 100), height, 0);
    fill(100);
    noStroke();
    rotateX(PI / 2);
    rect(0, 0, 100, carreteraLargo * 10);
    popMatrix();
  }

  // Postes de luz (izquierda y derecha)
  for (int i = -10; i < 10; i++) {
    for (int side = -1; side <= 1; side += 2) { 
      pushMatrix();
      float xOffset = width / 2 + side * (carreteraAncho / 2 + 150);
      translate(xOffset, height - 100, i * 500 + desplazamientoLineas);
      fill(200);
      noStroke();
      rotateX(PI / 2);
      box(10, 10, 200);

      pushMatrix();
      translate(45 * -side, 0, 60); 
      box(100, 10, 10);
      popMatrix();

      translate(82 * -side, 0, 42);
      fill(255, 255, 0);
      
      // Simulación de bombilla brillante sin luz puntual
      emissive(255, 255, 150); 
      sphere(15);
      emissive(0); // Restablecer para evitar afectar otros objetos

      popMatrix();
    }
  }
}

//reinicar obstaculos
void reiniciarAuto(int i) {
  // Asignar carril aleatorio
  obstaculoX[i] = random(-carreteraAncho / 2 + carrilAncho / 2, carreteraAncho / 2 - carrilAncho / 2);
  obstaculoZ[i] = random(-5000, -1000); 
  int modeloAleatorio = int(random(5));
  modelosAutos[i] = autos[modeloAleatorio];
}


//metodo game over
void mostrarGameOver() {

  
  background(0); // Fondo negro para la pantalla de Game Over
  textSize(60);
  textAlign(CENTER, CENTER);
  fill(255, 0, 0);
  text("Game Over", width / 2, height / 3);
  fill(255);
  text("Puntuación: " + puntuacion, width / 2, height / 2);

  fill(120);
  noStroke();
  rectMode(CENTER);
  rect(width / 2, height / 1.3, 220, 80, 20);
  fill(255);
  text("Reiniciar", width / 2, height / 1.3);
}

void salirAlMenu() {
  // Reiniciar todas las variables y estados
  enGameOver = false;
  enMenu = true;
  enSeleccion = false;
  enJuego = false;
  
  puntuacion = 0;
  tiempoInicial = millis();
  tiempoPuntuacion = 0;
  velocidadObstaculos = 5;
  jugadorX = 0;
  
  jugadorZ = 100;

  // Reiniciar posiciones de los autos
  for (int i = 0; i < numObstaculos; i++) {
    reiniciarAuto(i);
  }
}

void keyPressed() {
  if (key == 'v' || key == 'V') {  // Vista principal
    cam = new PeasyCam(this, 100);  
    cam.lookAt(650, 400, 600);     
    cam.setMinimumDistance(0);     
    cam.setMaximumDistance(400);   
  } 
  else if (key == 'b' || key == 'B') {  // Vista alternativa
     cam = new PeasyCam(this, 100);  
    cam.lookAt(650, 550, 180);     
    cam.setMinimumDistance(0);     
    cam.setMaximumDistance(400);             
  }
}
