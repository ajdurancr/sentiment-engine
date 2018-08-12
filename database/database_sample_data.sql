--
-- PostgreSQL database dump
--

-- Dumped from database version 10.5
-- Dumped by pg_dump version 10.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: historicalKnowledge; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: knowledge; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.knowledge ("knowledgeId", name) VALUES (1, 'Historical');


--
-- Data for Name: knowledgeModel; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."knowledgeModel" ("knowledgeModelId", name, alpha, percentiles, "percentilesToTake") VALUES (1, 'Default model a1.96 - p9 - pt3', 1.96, 9, 3);
INSERT INTO public."knowledgeModel" ("knowledgeModelId", name, alpha, percentiles, "percentilesToTake") VALUES (2, 'Default model a1.96 - p7 - pt3', 1.96, 7, 3);


--
-- Data for Name: sentiment; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sentiment ("sentimentId", name) VALUES (1, 'Positive');
INSERT INTO public.sentiment ("sentimentId", name) VALUES (2, 'Negative');


--
-- Name: knowledgeModel_knowledgeModelId_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."knowledgeModel_knowledgeModelId_seq"', 2, true);


--
-- Name: knowledge_knowledgeId_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."knowledge_knowledgeId_seq"', 1, true);


--
-- Name: sentiment_sentimentId_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."sentiment_sentimentId_seq"', 2, true);


--
-- PostgreSQL database dump complete
--

