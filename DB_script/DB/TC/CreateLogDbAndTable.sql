CREATE DATABASE LogDb

USE LogDb
GO
CREATE TABLE [dbo].[tblThirdParty_ApiDetailLog] (
    [rowId]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [processId]       VARCHAR (40)   NULL,
    [date]            DATETIME       NULL,
    [thread]          VARCHAR (255)  NULL,
    [level]           VARCHAR (255)  NULL,
    [logger]          NVARCHAR (255)  NULL,
    [message]         NVARCHAR (MAX)  NULL,
    [exception]       NVARCHAR (MAX)  NULL,
    [logBy]           VARCHAR (100)  NULL,
    [Provider]        VARCHAR (30)   NULL,
    [ClientIpAddress] NVARCHAR (128) NULL,
    [UserName]        NVARCHAR (150) NULL,
	[ControlNo]		  VARCHAR(50) NULL
    PRIMARY KEY CLUSTERED ([rowId] ASC)
);

