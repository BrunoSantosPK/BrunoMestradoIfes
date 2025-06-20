//*********************
//**Criado pelo ChatGPT
//*********************

int diasPorSemana = ...;
int aulasPorDia = ...;
int totalTurmas = ...;
int totalProfessores = ...;



range Dia = 1..diasPorSemana;
range Horario = 1..aulasPorDia;

// Defini��o dos professores e suas turmas
range Professores = 1..totalProfessores;
range Turmas = 1..totalTurmas;

// Aulas por semana para cada professor
//int aulasPorSemana[Professores] = [4, 4, 4, 4, 2, 2, 2, 2, 2, 1, 2, 2, 1, 2, 1];

// Turmas atribu�das a cada professor
int ProfTurma[Professores][Turmas] = ...;

// Vari�veis de decis�o
dvar boolean x[Horario][Dia][Turmas][Professores];

// Restri��es
maximize sum(a in Horario, b in Dia, c in Turmas, d in Professores) x[a][b][c][d];

subject to {
    // Cada turma tem no m�ximo uma aula por dia com cada professor
    forall(d in Dia, t in Turmas, p in Professores) {
        sum(a in Horario) x[a][d][t][p] <= 1;
    }

    // Em cada hor�rio de uma dada turma s� pode existir um professor na sala de aula
    forall(d in Dia, a in Horario, t in Turmas) {
            sum(p in Professores) x[a][d][t][p] <= 1;
    }

	// Cada professor s� pode estar um uma sala de cada vez
    forall(d in Dia, a in Horario, p in Professores) {
            sum(t in Turmas) x[a][d][t][p] <= 1;
    }

	//Aloca��o do n�mero de aulas de cada professor
	forall(p in Professores, t in Turmas) {
        sum(d in Dia, a in Horario) x[a][d][t][p] <= ProfTurma[p][t];
    }
    
   forall(t in Turmas,a in Horario, d in {1,3,4})
   	x[a][d][t][6] == 0;   
  }    
// Output da solu��o x[a][d][t][6] ==�0;
execute {
    writeln("Grade de Hor�rios Escolares:");
    for (var d in Dia) {
        writeln("Dia ", d);
        for (var a in Horario) {
            writeln("Aula ", a);
            for (var t in Turmas) {
                for (var p in Professores) {
                    if (x[d][a][t][p] == 1) {
                        writeln("Turma ", t, " - Professor ", p);
                    }
                }
            }
        }
    }
}
