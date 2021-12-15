USE mavenfuzzyfactory;

--FINDING TOP Traffic Sources
	--utm_source, campagn, http_referer
	--WHERE created at less than 2021-04-12
	--GROUP BY
	--ORDER BY

--Test Result
SELECT utm_source, utm_campaign, http_referer,
COUNT(distinct website_sessions.website_session_id) as sessions
FROM website_sessions


--Final Outlook
SELECT utm_source, utm_campaign, http_referer,
COUNT(distinct website_session_id) as number_of_sessions
FROM website_sessions
WHERE created_at < '2021-04-12'
GROUP BY utm_source, utm_campaign, http_referer
ORDER by number_of_sessions DESC