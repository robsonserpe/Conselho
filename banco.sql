-- ============================================================================
-- SCRIPT SQL COMPLETO — PRÉ-CONSELHO DIGITAL (SUPABASE)
-- ============================================================================

-- 1. TABELA DE USUÁRIOS (DIRETORA E PROFESSORES)
CREATE TABLE IF NOT EXISTS public.users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  username TEXT NOT NULL,
  email TEXT,
  password TEXT NOT NULL DEFAULT '123',
  role TEXT NOT NULL CHECK (role IN ('diretora', 'professor')),
  subject TEXT DEFAULT '',
  subjects JSONB DEFAULT '[]'::jsonb,
  classes JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. TABELA DE MATÉRIAS / COMPONENTES CURRICULARES
CREATE TABLE IF NOT EXISTS public.school_subjects (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. TABELA DE TURMAS
CREATE TABLE IF NOT EXISTS public.school_classes (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  grade TEXT,
  shift TEXT DEFAULT 'Matutino',
  year INTEGER DEFAULT 2026,
  room TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. TABELA DE ESTUDANTES
CREATE TABLE IF NOT EXISTS public.students (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  roll_number TEXT DEFAULT '',
  class_group TEXT NOT NULL,
  status TEXT DEFAULT 'ativo',
  notes TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. TABELA DE SEÇÕES DO QUESTIONÁRIO
CREATE TABLE IF NOT EXISTS public.question_sections (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  "order" INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. TABELA DE PERGUNTAS OFICIAIS
CREATE TABLE IF NOT EXISTS public.questions (
  id TEXT PRIMARY KEY,
  section_id TEXT NOT NULL REFERENCES public.question_sections(id) ON DELETE CASCADE,
  prompt TEXT NOT NULL,
  placeholder TEXT DEFAULT '',
  required BOOLEAN NOT NULL DEFAULT TRUE,
  "order" INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. TABELA DE FICHAS / RELATÓRIOS DE PRÉ-CONSELHO
CREATE TABLE IF NOT EXISTS public.pre_council_reports (
  id TEXT PRIMARY KEY,
  school_name TEXT NOT NULL,
  school_subtitle TEXT NOT NULL,
  title TEXT NOT NULL,
  teacher_id TEXT NOT NULL,
  teacher_name TEXT NOT NULL,
  component TEXT NOT NULL,
  class_group TEXT NOT NULL,
  date TEXT NOT NULL,
  trimester TEXT NOT NULL,
  answers JSONB DEFAULT '{}'::jsonb,
  dimension_ratings JSONB DEFAULT '{}'::jsonb,
  student_ratings JSONB DEFAULT '{}'::jsonb,
  status TEXT NOT NULL DEFAULT 'pendente',
  pedagoga_signature JSONB DEFAULT '{"signed": false}'::jsonb,
  diretora_signature JSONB DEFAULT '{"signed": false}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- ÍNDICES DE PERFORMANCE
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_students_class_group ON public.students(class_group);
CREATE INDEX IF NOT EXISTS idx_questions_section_id ON public.questions(section_id);
CREATE INDEX IF NOT EXISTS idx_reports_teacher_id ON public.pre_council_reports(teacher_id);
CREATE INDEX IF NOT EXISTS idx_reports_trimester ON public.pre_council_reports(trimester);

-- ============================================================================
-- POLÍTICAS DE ACESSO (RLS) PARA FUNCIONAR DIRETO COM A CHAVE ANON DO HTML
-- ============================================================================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.school_subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.school_classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.question_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pre_council_reports ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Acesso total users" ON public.users;
CREATE POLICY "Acesso total users" ON public.users FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Acesso total school_subjects" ON public.school_subjects;
CREATE POLICY "Acesso total school_subjects" ON public.school_subjects FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Acesso total school_classes" ON public.school_classes;
CREATE POLICY "Acesso total school_classes" ON public.school_classes FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Acesso total students" ON public.students;
CREATE POLICY "Acesso total students" ON public.students FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Acesso total question_sections" ON public.question_sections;
CREATE POLICY "Acesso total question_sections" ON public.question_sections FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Acesso total questions" ON public.questions;
CREATE POLICY "Acesso total questions" ON public.questions FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Acesso total pre_council_reports" ON public.pre_council_reports;
CREATE POLICY "Acesso total pre_council_reports" ON public.pre_council_reports FOR ALL USING (true) WITH CHECK (true);

-- ============================================================================
-- DADOS INICIAIS (DIRETORA, MATÉRIAS, SEÇÕES E PERGUNTAS OFICIAIS)
-- ============================================================================
INSERT INTO public.users (id, name, username, email, password, role, subject, subjects, classes)
VALUES (
  'dir-1',
  'Diretora',
  'Diretora',
  'direcao@freigraciano.pr.gov.br',
  '123',
  'diretora',
  '',
  '[]'::jsonb,
  '[]'::jsonb
) ON CONFLICT (id) DO NOTHING;

INSERT INTO public.school_subjects (id, name) VALUES
  ('subj-1', 'Arte'),
  ('subj-2', 'Biologia'),
  ('subj-3', 'Ciências'),
  ('subj-4', 'Educação Física'),
  ('subj-5', 'Ensino Religioso'),
  ('subj-6', 'Filosofia'),
  ('subj-7', 'Física'),
  ('subj-8', 'Geografia'),
  ('subj-9', 'História'),
  ('subj-10', 'Língua Inglesa'),
  ('subj-11', 'Língua Portuguesa'),
  ('subj-12', 'Matemática'),
  ('subj-13', 'Projeto de Vida'),
  ('subj-14', 'Química'),
  ('subj-15', 'Sociologia')
ON CONFLICT (name) DO NOTHING;

INSERT INTO public.question_sections (id, title, "order") VALUES
  ('sec-1', '1. PANORAMA DA TURMA', 1),
  ('sec-2', '2. APRENDIZAGEM E FREQUÊNCIA', 2),
  ('sec-3', '3. DESTAQUES E SITUAÇÕES QUE MERECEM ATENÇÃO', 3),
  ('sec-4', '4. ENCAMINHAMENTOS', 4),
  ('sec-5', '5. SÍNTESE DO PROFESSOR', 5),
  ('sec-6', '6. Alunos abaixo da média 6.0 e estratégias de recuperação:', 6)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.questions (id, section_id, prompt, placeholder, required, "order") VALUES
  ('q-1', 'sec-1', 'Como você avalia o desenvolvimento geral da turma em relação à aprendizagem?', 'Ex: A turma demonstra bom ritmo nas explicações iniciais, porém apresenta heterogeneidade na consolidação dos conceitos...', true, 1),
  ('q-2', 'sec-1', 'Como está a participação, o envolvimento e a postura dos estudantes nas aulas?', 'Ex: Boa participação oral nos debates coletivos, com momentos de dispersão no final do período vespertino...', true, 2),
  ('q-3', 'sec-2', 'Quais habilidades/conteúdos apresentam maior dificuldade para a turma?', 'Ex: Interpretação de problemas contextualizados e operações com frações/geometria plana...', true, 1),
  ('q-4', 'sec-2', 'Há estudantes com baixa frequência ou que necessitam de acompanhamento mais próximo? Quais e por quê?', 'Ex: Aluno Marcos Vinicius (faltas frequentes às terças-feiras); Aluna Júlia (dificuldade motora/leitura)...', true, 2),
  ('q-5', 'sec-3', 'Estudantes que apresentam dificuldades significativas ou necessitam de intervenção/encaminhamento:', 'Ex: Rafael Costa (necessita reforço pedagógico urgente em leitura/interpretação), Matheus Lima (questão de convivência em equipe)...', true, 1),
  ('q-6', 'sec-3', 'Problemas de comportamentos que merecem atenção:', 'Ex: Palavrões, brigas, discussões, falta de respeito etc..', true, 2),
  ('q-7', 'sec-4', 'Quais estratégias já foram realizadas e quais ações você sugere para o próximo período?', 'Ex: Realizada monitoria entre pares e listas graduadas de exercícios. Sugiro oficinas práticas no contraturno...', true, 1),
  ('q-8', 'sec-5', 'Deixe aqui uma observação geral sobre a turma que considere relevante para o Conselho de Classe:', 'Ex: Turma com alto potencial cognitivo que responde muito bem a projetos práticos...', true, 1),
  ('q-9', 'sec-6', 'Quem são os alunos abaixo da média:', 'Cite os nomes dos alunos.', true, 1),
  ('q-10', 'sec-6', 'Quais recursos, estratégias e intervenções pedagógicas foram utilizadas para minimizar ou sanar as dificuldades de aprendizagem dos estudantes abaixo da média:', 'Ex: O que foi feito, como foi feito, quais encaminhamentos e instrumentos pedagógicos...', true, 2)
ON CONFLICT (id) DO NOTHING;
